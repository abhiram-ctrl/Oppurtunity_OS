const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const { google } = require('googleapis');

const Opportunity = require('../models/Opportunity');
const { extractOpportunityFromText, isEmailRelevantToInternship } = require('./geminiService');

const DEFAULT_MAX_RESULTS = 10;

const normalizeText = (value = '') => value.replace(/\s+/g, ' ').trim();

const decodeBase64Url = (value = '') => {
  const normalized = value.replace(/-/g, '+').replace(/_/g, '/');
  const padded = normalized + '='.repeat((4 - (normalized.length % 4)) % 4);
  return Buffer.from(padded, 'base64').toString('utf8');
};

const extractHeader = (headers = [], key) => {
  const found = headers.find((header) => header?.name?.toLowerCase() === key.toLowerCase());
  return found?.value || '';
};

const collectBodyChunks = (payload) => {
  const chunks = [];

  const visit = (node) => {
    if (!node) {
      return;
    }

    if (node?.body?.data) {
      const decoded = decodeBase64Url(node.body.data);
      if (decoded) {
        chunks.push(decoded);
      }
    }

    if (Array.isArray(node?.parts)) {
      node.parts.forEach(visit);
    }
  };

  visit(payload);

  const raw = chunks.join('\n').trim();
  if (!raw) {
    return '';
  }

  // Basic HTML stripping fallback for text/html bodies.
  return raw
    .replace(/<style[\s\S]*?<\/style>/gi, ' ')
    .replace(/<script[\s\S]*?<\/script>/gi, ' ')
    .replace(/<[^>]+>/g, ' ')
    .replace(/&nbsp;/gi, ' ')
    .replace(/&amp;/gi, '&')
    .replace(/\s+/g, ' ')
    .trim();
};

const extractLinks = (text = '') => {
  const matches = text.match(/https?:\/\/[^\s)]+/gi) || [];
  return Array.from(new Set(matches.map((url) => url.replace(/[),.]+$/, ''))));
};

const toCanonicalDate = (value) => {
  const parsed = new Date(value);
  if (Number.isNaN(parsed.getTime())) {
    return null;
  }

  return new Date(Date.UTC(parsed.getUTCFullYear(), parsed.getUTCMonth(), parsed.getUTCDate(), 12));
};

const fallbackDeadlineDate = () => {
  const now = new Date();
  return new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate() + 14, 12));
};

const getDeadlineBounds = (value) => {
  const deadline = toCanonicalDate(value);
  if (!deadline) {
    return null;
  }

  return {
    start: new Date(Date.UTC(deadline.getUTCFullYear(), deadline.getUTCMonth(), deadline.getUTCDate(), 0, 0, 0, 0)),
    end: new Date(Date.UTC(deadline.getUTCFullYear(), deadline.getUTCMonth(), deadline.getUTCDate(), 23, 59, 59, 999)),
  };
};

const readJson = (absolutePath) => JSON.parse(fs.readFileSync(absolutePath, 'utf8'));

const resolveGoogleCredentialBlock = (credentialsJson) => {
  if (credentialsJson.installed) {
    return credentialsJson.installed;
  }

  if (credentialsJson.web) {
    return credentialsJson.web;
  }

  throw new Error('credentials.json must contain an "installed" or "web" object');
};

const buildOAuthClient = ({ credentialsPath, tokenPath }) => {
  const credentials = readJson(credentialsPath);
  const clientConfig = resolveGoogleCredentialBlock(credentials);

  const oauth2Client = new google.auth.OAuth2(
    clientConfig.client_id,
    clientConfig.client_secret,
    clientConfig.redirect_uris?.[0],
  );

  if (!fs.existsSync(tokenPath)) {
    throw new Error(
      `Missing token file at ${tokenPath}. Complete OAuth consent once and save token.json before running ingestion.`,
    );
  }

  const token = readJson(tokenPath);
  oauth2Client.setCredentials(token);

  return oauth2Client;
};

const buildOpportunitySourceText = ({ subject, body, links, from, date }) => {
  return [
    `Subject: ${subject || ''}`,
    `From: ${from || ''}`,
    `Date: ${date || ''}`,
    '',
    'Body:',
    body || '',
    '',
    links.length > 0 ? `Links:\n${links.join('\n')}` : 'Links:\nNone',
  ]
    .join('\n')
    .trim();
};

const findDuplicateByCoreFields = async ({ company, role, deadline }) => {
  const bounds = getDeadlineBounds(deadline);
  if (!bounds) {
    return null;
  }

  return Opportunity.findOne({
    company: { $regex: `^${company}$`, $options: 'i' },
    role: { $regex: `^${role}$`, $options: 'i' },
    deadline: { $gte: bounds.start, $lt: bounds.end },
  });
};

const processOneMessage = async (gmail, messageId) => {
  const full = await gmail.users.messages.get({
    userId: 'me',
    id: messageId,
    format: 'full',
  });

  const payload = full.data?.payload || {};
  const headers = payload.headers || [];

  const subject = normalizeText(extractHeader(headers, 'Subject'));
  const from = normalizeText(extractHeader(headers, 'From'));
  const date = normalizeText(extractHeader(headers, 'Date'));
  const body = collectBodyChunks(payload);
  const links = extractLinks(body);

  const sourceText = buildOpportunitySourceText({ subject, body, links, from, date });

  // Gemini relevance pre-screen: skip promotions, ads, and unrelated emails
  const isRelevant = await isEmailRelevantToInternship(sourceText);
  if (!isRelevant) {
    console.log(`🚫 Gmail email skipped (not internship-related): ${subject}`);
    return {
      status: 'skipped',
      reason: 'Not an internship/opportunity email — filtered by Gemini',
      subject,
    };
  }

  // Gemini extraction — required, no silent fallback
  let extracted;
  try {
    extracted = await extractOpportunityFromText(sourceText);
    console.log(`[Gemini] Gmail extraction OK: ${extracted.company} | ${extracted.role}`);
  } catch (geminiError) {
    console.error(`[Gemini] Gmail extraction failed for "${subject}": ${geminiError.message}`);
    return {
      status: 'skipped',
      reason: `Gemini extraction failed: ${geminiError.message}`,
      subject,
    };
  }

  const company = normalizeText(extracted.company || '');
  const role = normalizeText(extracted.role || '');

  if (!company || !role) {
    return {
      status: 'skipped',
      reason: 'Gemini could not extract company/role',
      subject,
    };
  }

  const deadline = toCanonicalDate(extracted.deadline) || fallbackDeadlineDate();

  // Dedup layer 1: content hash (company + role + deadline) — catches WhatsApp↔Gmail same content
  const contentHash = crypto
    .createHash('sha256')
    .update(`${company.toLowerCase()}|${role.toLowerCase()}|${deadline.toISOString().slice(0, 10)}`)
    .digest('hex');

  const duplicateByContentHash = await Opportunity.findOne({ contentHash });
  if (duplicateByContentHash) {
    if (!duplicateByContentHash.sources.includes('gmail')) {
      duplicateByContentHash.sources.push('gmail');
      await duplicateByContentHash.save();
      console.log(`📧 Merged Gmail source into existing opportunity (content hash): ${duplicateByContentHash._id}`);
    }
    return {
      status: 'duplicate',
      reason: 'Duplicate by content hash (company+role+deadline)',
      subject,
      opportunityId: duplicateByContentHash._id.toString(),
    };
  }

  // Dedup layer 2: company + role + deadline window (strict regex match)
  const duplicateByCoreFields = await findDuplicateByCoreFields({ company, role, deadline });
  if (duplicateByCoreFields) {
    if (!duplicateByCoreFields.sources.includes('gmail')) {
      duplicateByCoreFields.sources.push('gmail');
      if (!duplicateByCoreFields.contentHash) {
        duplicateByCoreFields.contentHash = contentHash;
      }
      await duplicateByCoreFields.save();
      console.log(`📧 Merged Gmail source into existing opportunity (core fields): ${duplicateByCoreFields._id}`);
    }
    return {
      status: 'duplicate',
      reason: 'Duplicate by company + role + deadline',
      subject,
      opportunityId: duplicateByCoreFields._id.toString(),
    };
  }

  // Dedup layer 3: Gmail message fingerprint
  const messageFingerprint = crypto
    .createHash('sha256')
    .update(`gmail:${messageId}`)
    .digest('hex');

  const duplicateByFingerprint = await Opportunity.findOne({ messageHash: messageFingerprint });
  if (duplicateByFingerprint) {
    if (!duplicateByFingerprint.sources.includes('gmail')) {
      duplicateByFingerprint.sources.push('gmail');
      await duplicateByFingerprint.save();
    }
    return {
      status: 'duplicate',
      reason: 'Duplicate by Gmail message fingerprint',
      subject,
      opportunityId: duplicateByFingerprint._id.toString(),
    };
  }

  const opportunity = await Opportunity.create({
    company,
    role,
    category: extracted.category || 'General',
    summary: normalizeText(extracted.summary || body.slice(0, 260) || subject),
    deadline,
    apply_link: extracted.apply_link || links[0] || 'Not provided in source message',
    messageHash: messageFingerprint,
    contentHash,
    rawMessage: sourceText,
    sourceTitle: subject,
    sources: ['gmail'],
  });

  console.log(`📧 Gmail opportunity detected: ${subject || `${company} ${role}`}`);

  return {
    status: 'saved',
    subject,
    opportunityId: opportunity._id.toString(),
  };
};

const processRecentOpportunityEmails = async ({
  credentialsPath = process.env.GMAIL_CREDENTIALS_PATH || '/etc/secrets/credentials.json',
  tokenPath = process.env.GMAIL_TOKEN_PATH || '/etc/secrets/token.json',
  maxResults = DEFAULT_MAX_RESULTS,
} = {}) => {
  const auth = buildOAuthClient({ credentialsPath, tokenPath });
  const gmail = google.gmail({ version: 'v1', auth });

  console.log('📥 Checking Gmail inbox for internship-related emails (last 24 hours)...');

  const listResponse = await gmail.users.messages.list({
    userId: 'me',
    q: 'newer_than:1d (internship OR "job opening" OR "apply now" OR hiring OR fellowship OR intern OR opportunity OR placement OR "career opportunity") -category:promotions -category:social -category:updates -category:forums -category:reservations',
    maxResults,
  });

  const messageIds = (listResponse.data?.messages || []).map((item) => item.id).filter(Boolean);

  if (messageIds.length === 0) {
    console.log('ℹ️ No Gmail messages found in the last 24 hours.');
    return { saved: 0, duplicates: 0, skipped: 0, totalFetched: 0, details: [] };
  }

  let saved = 0;
  let duplicates = 0;
  let skipped = 0;
  const details = [];

  for (const messageId of messageIds) {
    try {
      const result = await processOneMessage(gmail, messageId);
      details.push(result);

      if (result.status === 'saved') {
        saved += 1;
      } else if (result.status === 'duplicate') {
        duplicates += 1;
      } else {
        skipped += 1;
      }
    } catch (error) {
      skipped += 1;
      details.push({
        status: 'skipped',
        reason: error.message,
      });
      console.error('⚠️ Failed processing Gmail message:', error.message);
    }
  }

  console.log(
    `✅ Gmail ingestion complete. fetched=${messageIds.length} saved=${saved} duplicate=${duplicates} skipped=${skipped}`,
  );

  return {
    saved,
    duplicates,
    skipped,
    totalFetched: messageIds.length,
    details,
  };
};

const startGmailIngestion = async () => {
  const cron = require('node-cron');
  const credentialsPath = process.env.GMAIL_CREDENTIALS_PATH || '/etc/secrets/credentials.json';
  const tokenPath = process.env.GMAIL_TOKEN_PATH || '/etc/secrets/token.json';

  // Check if credentials exist
  if (!fs.existsSync(credentialsPath)) {
    console.warn('⚠️ Gmail credentials not found. Skipping Gmail ingestion.');
    return;
  }

  // Check if tokens exist
  if (!fs.existsSync(tokenPath)) {
    console.warn('⚠️ Gmail tokens not found. To enable Gmail ingestion:');
    console.warn('   1. Run: node backend/scripts/gmailAuthSetup.js');
    console.warn('   2. Follow the authentication flow');
    console.warn('   3. Restart the server');
    return;
  }

  // Schedule to run every 6 hours
  cron.schedule('0 */6 * * *', async () => {
    console.log('🔄 Starting scheduled Gmail ingestion...');
    try {
      await processRecentOpportunityEmails({
        credentialsPath,
        tokenPath,
        maxResults: Number(process.env.GMAIL_MAX_RESULTS || 20),
      });
    } catch (error) {
      console.error('❌ Scheduled Gmail ingestion failed:', error.message);
    }
  });

  console.log('📧 Gmail ingestion cron started (runs every 6 hours).');

  // Run once on startup
  try {
    await processRecentOpportunityEmails({
      credentialsPath,
      tokenPath,
      maxResults: Number(process.env.GMAIL_MAX_RESULTS || 20),
    });
  } catch (error) {
    console.error('❌ Initial Gmail ingestion failed:', error.message);
  }
};

module.exports = {
  processRecentOpportunityEmails,
  startGmailIngestion,
};
