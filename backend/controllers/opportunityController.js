const Opportunity = require('../models/Opportunity');
const { extractOpportunityFromText, isEmailRelevantToInternship } = require('../services/geminiService');
const crypto = require('crypto');

const DEFAULT_DEADLINE_DAYS = 14;

const toDeadlineDate = (value) => {
  if (!value) {
    return null;
  }

  const date = new Date(value);
  if (Number.isNaN(date.getTime())) {
    return null;
  }

  return new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate(), 12));
};

const fallbackDeadlineDate = () => {
  const now = new Date();
  return new Date(
    Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate() + DEFAULT_DEADLINE_DAYS, 12),
  );
};

const normalizeText = (value) => value.replace(/\s+/g, ' ').trim();

const buildReadableMessage = ({ title, message }) => {
  const normalizedTitle = normalizeText(title || '');
  const normalizedMessage = normalizeText(message || '');

  if (!normalizedTitle) {
    return normalizedMessage;
  }

  if (normalizedMessage.toLowerCase().startsWith(normalizedTitle.toLowerCase())) {
    return normalizedMessage;
  }

  return `${normalizedTitle}: ${normalizedMessage}`;
};

const buildMessageHash = (message) =>
  crypto.createHash('sha256').update(normalizeText(message).toLowerCase()).digest('hex');

const getDeadlineBounds = (value) => {
  const deadline = toDeadlineDate(value);
  if (!deadline) {
    return null;
  }

  const start = new Date(
    Date.UTC(deadline.getUTCFullYear(), deadline.getUTCMonth(), deadline.getUTCDate(), 0, 0, 0, 0),
  );
  const end = new Date(
    Date.UTC(deadline.getUTCFullYear(), deadline.getUTCMonth(), deadline.getUTCDate(), 23, 59, 59, 999),
  );

  return { start, end };
};

const extractFirstUrl = (text) => {
  if (!text) {
    return null;
  }

  const urlMatch = text.match(/https?:\/\/[^\s]+/i);
  if (urlMatch) {
    return urlMatch[0].replace(/[),.]+$/, '');
  }

  const emailMatch = text.match(/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}/i);
  return emailMatch ? `mailto:${emailMatch[0]}` : null;
};

const getOpportunities = async (req, res) => {
  try {
    const opportunities = await Opportunity.find().sort({ createdAt: -1 });
    res.status(200).json(opportunities);
  } catch (error) {
    res.status(500).json({ message: 'Failed to fetch opportunities' });
  }
};

/**
 * Import notification and extract opportunity using Gemini AI
 * Flow: Receive message → Send to Gemini → Extract data → Store in MongoDB → Prevent duplicates
 */
const importNotification = async (req, res) => {
  try {
    const { message, title = '' } = req.body;

    if (!message || typeof message !== 'string') {
      return res.status(400).json({ message: 'Message field is required and must be a string' });
    }

    const readableMessage = buildReadableMessage({ title, message });
    const messageHash = buildMessageHash(readableMessage);

    const duplicateByMessage = await Opportunity.findOne({ messageHash });
    if (duplicateByMessage) {
      console.log('Duplicate opportunity ignored by message fingerprint');
      if (!duplicateByMessage.sources.includes('whatsapp_notification')) {
        duplicateByMessage.sources.push('whatsapp_notification');
        await duplicateByMessage.save();
      }
      return res.status(409).json({
        message: 'Opportunity already exists',
        opportunity: duplicateByMessage,
      });
    }

    // Step 1: Relevance filter — reject spam, personal, promotional messages
    const isRelevant = await isEmailRelevantToInternship(readableMessage);
    if (!isRelevant) {
      console.log(`🚫 Notification skipped (not internship-related): ${title || message.slice(0, 60)}`);
      return res.status(400).json({
        message: 'Message does not appear to be an internship or job opportunity. Skipped.',
      });
    }

    // Step 2: Extract structured data using Gemini (required — no silent fallback)
    console.log('[Gemini] Extracting opportunity data from WhatsApp message...');
    let extractedData;
    try {
      extractedData = await extractOpportunityFromText(readableMessage);
      console.log('[Gemini] Extraction successful:', extractedData.company, '|', extractedData.role);
    } catch (geminiError) {
      console.error('[Gemini] Failed to extract opportunity:', geminiError.message);
      return res.status(503).json({
        message: 'Gemini AI service unavailable. Please retry.',
        error: geminiError.message,
      });
    }

    // Step 3: Validate required fields
    const normalizedData = {
      company: extractedData.company || null,
      role: extractedData.role || null,
      category: extractedData.category || 'General',
      summary: extractedData.summary || readableMessage.trim().slice(0, 280),
      deadline: toDeadlineDate(extractedData.deadline) || fallbackDeadlineDate(),
      apply_link:
        extractedData.apply_link ||
        extractFirstUrl(readableMessage) ||
        'Not provided in source message',
    };

    const { company, role, deadline, category, summary, apply_link } = normalizedData;

    if (!company || !role) {
      return res.status(400).json({
        message: 'Could not extract the core opportunity fields from the message',
        extractedData: normalizedData,
      });
    }

    const deadlineBounds = getDeadlineBounds(deadline);

    // Step 4a: Deduplicate by content hash (normalized summary — catches cross-source same content)
    const contentHash = buildMessageHash(`${company}|${role}|${deadline.toISOString().slice(0, 10)}`);
    const duplicateByContent = await Opportunity.findOne({ contentHash });
    if (duplicateByContent) {
      if (!duplicateByContent.sources.includes('whatsapp_notification')) {
        duplicateByContent.sources.push('whatsapp_notification');
        await duplicateByContent.save();
        console.log('Merged WhatsApp source into existing opportunity by content hash:', duplicateByContent._id);
      }
      return res.status(409).json({ message: 'Opportunity already exists', opportunity: duplicateByContent });
    }

    // Step 4b: Deduplicate by company + role + deadline window
    console.log(`Checking for duplicates: ${company} | ${role} | ${deadline}`);
    const duplicateOpportunity = deadlineBounds
      ? await Opportunity.findOne({
          company: { $regex: `^${company}$`, $options: 'i' },
          role: { $regex: `^${role}$`, $options: 'i' },
          deadline: { $gte: deadlineBounds.start, $lt: deadlineBounds.end },
        })
      : null;

    if (duplicateOpportunity) {
      if (!duplicateOpportunity.sources.includes('whatsapp_notification')) {
        duplicateOpportunity.sources.push('whatsapp_notification');
        if (!duplicateOpportunity.contentHash) {
          duplicateOpportunity.contentHash = contentHash;
        }
        await duplicateOpportunity.save();
        console.log('Merged WhatsApp source into existing opportunity:', duplicateOpportunity._id);
      }
      return res.status(409).json({
        message: 'Opportunity already exists',
        opportunity: duplicateOpportunity,
      });
    }

    // Step 5: Create and save new opportunity
    console.log('Creating new opportunity...');
    const newOpportunity = new Opportunity({
      company,
      role,
      category,
      summary,
      deadline,
      apply_link,
      sources: ['whatsapp_notification'],
      messageHash,
      contentHash,
      rawMessage: readableMessage,
      sourceTitle: normalizeText(title || ''),
    });

    await newOpportunity.save();

    console.log('Opportunity saved successfully:', newOpportunity._id);
    res.status(201).json({
      message: 'Opportunity imported successfully',
      opportunity: newOpportunity,
    });
  } catch (error) {
    console.error('Error in importNotification:', error.message);
    res.status(500).json({
      message: 'Failed to process notification',
      error: error.message,
    });
  }
};

const deleteOpportunity = async (req, res) => {
  try {
    const { id } = req.params;
    const deleted = await Opportunity.findByIdAndDelete(id);
    if (!deleted) {
      return res.status(404).json({ message: 'Opportunity not found' });
    }
    res.status(200).json({ message: 'Opportunity deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Failed to delete opportunity', error: error.message });
  }
};

module.exports = {
  getOpportunities,
  importNotification,
  deleteOpportunity,
};
