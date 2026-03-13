const axios = require('axios');

const GEMINI_MODELS = ['gemini-2.0-flash', 'gemini-2.0-flash-lite', 'gemini-2.5-flash'];

const buildRelevancePrompt = (emailText) =>
  `You are a smart email filter for an internship tracking app.

Read the following email carefully. Reply ONLY with "YES" if it is about an internship, job opening, placement, fellowship, hiring announcement, or career opportunity. Reply ONLY with "NO" if it is a promotional email, newsletter, advertisement, OTP, receipt, social update, subscription offer, or anything unrelated to internships/jobs.

Email:
${emailText.slice(0, 2000)}

Answer with YES or NO only.`;

const buildPrompt = (rawText) => `Extract structured internship/opportunity information from the following text and respond ONLY with a valid JSON object — no markdown, no code fences, no extra text.

Text: ${JSON.stringify(rawText)}

Return ONLY this exact JSON structure (use null if a field cannot be determined):
{
  "company": "company or organization name",
  "role": "exact job/internship title",
  "category": "MUST be exactly one of: AI/ML, Data Science, Web Development, Mobile Development, Cloud / DevOps, Cybersecurity, Genomics / Life Sciences, General",
  "summary": "2-3 clear sentences: what the company does and what the intern will work on",
  "deadline": "application deadline in YYYY-MM-DD format, or null",
  "apply_link": "full application URL or mailto:email, or null"
}

Category selection rules:
- AI/ML → machine learning, artificial intelligence, NLP, computer vision, deep learning
- Data Science → data analysis, data engineering, analytics, BI, SQL, ETL, data pipelines
- Web Development → frontend, backend, full stack, React, Node, JavaScript, HTML, CSS
- Mobile Development → Android, iOS, Flutter, React Native
- Cloud / DevOps → cloud, AWS, Azure, GCP, Docker, Kubernetes, CI/CD, DevOps, SRE
- Cybersecurity → security, penetration testing, ethical hacking, SOC, infosec
- Genomics / Life Sciences → genomics, bioinformatics, biotech, life sciences, biology
- General → anything else that doesn't fit above

If the text has no opportunity information, return the JSON with all null values.`;

const sanitizeGeminiJson = (text) => {
  const normalized = text.replace(/```json/gi, '').replace(/```/g, '').trim();
  const jsonMatch = normalized.match(/\{[\s\S]*\}/);

  if (!jsonMatch) {
    throw new Error('Failed to extract JSON from Gemini response');
  }

  return JSON.parse(jsonMatch[0]);
};

const toCanonicalDate = (date) =>
  new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate(), 12));

const MONTH_INDEX = {
  january: 0,
  february: 1,
  march: 2,
  april: 3,
  may: 4,
  june: 5,
  july: 6,
  august: 7,
  september: 8,
  october: 9,
  november: 10,
  december: 11,
  jan: 0,
  feb: 1,
  mar: 2,
  apr: 3,
  jun: 5,
  jul: 6,
  aug: 7,
  sep: 8,
  sept: 8,
  oct: 9,
  nov: 10,
  dec: 11,
};

const parseTextualDeadline = (value) => {
  if (!value) {
    return null;
  }

  const normalized = value.replace(/,/g, ' ').replace(/\s+/g, ' ').trim();

  const monthFirst = normalized.match(/^([A-Za-z]+)\s+(\d{1,2})\s+(20\d{2})$/i);
  if (monthFirst) {
    const month = MONTH_INDEX[monthFirst[1].toLowerCase()];
    if (month != null) {
      return new Date(Date.UTC(Number(monthFirst[3]), month, Number(monthFirst[2]), 12));
    }
  }

  const dayFirst = normalized.match(/^(\d{1,2})\s+([A-Za-z]+)\s+(20\d{2})$/i);
  if (dayFirst) {
    const month = MONTH_INDEX[dayFirst[2].toLowerCase()];
    if (month != null) {
      return new Date(Date.UTC(Number(dayFirst[3]), month, Number(dayFirst[1]), 12));
    }
  }

  return null;
};

const normalizeDeadline = (value) => {
  if (!value) {
    return null;
  }

  if (typeof value === 'string') {
    const textualDate = parseTextualDeadline(value);
    if (textualDate) {
      return textualDate;
    }
  }

  const parsed = new Date(value);
  return Number.isNaN(parsed.getTime()) ? null : toCanonicalDate(parsed);
};

const inferCategory = (text) => {
  const value = text.toLowerCase();

  if (
    value.includes('genomic') ||
    value.includes('genomics') ||
    value.includes('life science') ||
    value.includes('life sciences') ||
    value.includes('bioinformatics') ||
    value.includes('biotech') ||
    value.includes('biotechnology')
  ) {
    return 'Genomics / Life Sciences';
  }

  if (value.includes('ai') || value.includes('ml') || value.includes('machine learning')) {
    return 'AI/ML';
  }
  if (
    value.includes('data scientist') ||
    value.includes('data science') ||
    value.includes('data analyst') ||
    value.includes('analytics') ||
    value.includes('business intelligence') ||
    value.includes('data engineer')
  ) {
    return 'Data Science';
  }
  if (
    value.includes('flutter') ||
    value.includes('android') ||
    value.includes('ios') ||
    value.includes('mobile')
  ) {
    return 'Mobile Development';
  }
  if (
    value.includes('cloud') ||
    value.includes('devops') ||
    value.includes('aws') ||
    value.includes('azure') ||
    value.includes('kubernetes') ||
    value.includes('docker') ||
    value.includes('site reliability') ||
    value.includes('sre')
  ) {
    return 'Cloud / DevOps';
  }
  if (value.includes('security') || value.includes('cyber')) {
    return 'Cybersecurity';
  }
  if (
    value.includes('web') ||
    value.includes('frontend') ||
    value.includes('backend') ||
    value.includes('full stack') ||
    value.includes('software engineer') ||
    value.includes('software developer') ||
    value.includes('react') ||
    value.includes('node') ||
    value.includes('javascript')
  ) {
    return 'Web Development';
  }

  return 'General';
};

const extractDeadlineFromText = (text) => {
  const isoMatch = text.match(/\b(20\d{2}-\d{2}-\d{2})\b/);
  if (isoMatch) {
    return normalizeDeadline(isoMatch[1]);
  }

  const slashMatch = text.match(/\b(\d{1,2})[\/\-](\d{1,2})[\/\-](20\d{2})\b/);
  if (slashMatch) {
    const [, day, month, year] = slashMatch;
    return normalizeDeadline(`${year}-${month.padStart(2, '0')}-${day.padStart(2, '0')}`);
  }

  const slashShortYearMatch = text.match(/\b(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{2})\b/);
  if (slashShortYearMatch) {
    const [, day, month, shortYear] = slashShortYearMatch;
    const yearNum = Number(shortYear);
    const fullYear = yearNum >= 70 ? 1900 + yearNum : 2000 + yearNum;
    return normalizeDeadline(`${fullYear}-${month.padStart(2, '0')}-${day.padStart(2, '0')}`);
  }

  const monthMatch = text.match(
    /\b(?:deadline|apply by|last date|before)[:\s-]*([A-Z][a-z]+\s+\d{1,2},?\s+20\d{2})/i,
  );
  if (monthMatch) {
    return normalizeDeadline(monthMatch[1]);
  }

  const altMonthMatch = text.match(
    /\b(\d{1,2}\s+[A-Z][a-z]+\s+20\d{2})\b/i,
  );
  if (altMonthMatch) {
    return normalizeDeadline(altMonthMatch[1]);
  }

  const relativeDayMatch = text.match(/\b(?:in|within)\s+(\d{1,2})\s+days?\b/i);
  if (relativeDayMatch) {
    const now = new Date();
    return toCanonicalDate(
      new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate() + Number(relativeDayMatch[1]), 12)),
    );
  }

  if (/\btomorrow\b/i.test(text)) {
    const now = new Date();
    return toCanonicalDate(
      new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate() + 1, 12)),
    );
  }

  if (/\btoday\b/i.test(text)) {
    return toCanonicalDate(new Date());
  }

  return null;
};

const extractApplyLink = (text) => {
  const urlMatch = text.match(/https?:\/\/[^\s]+/i);
  if (urlMatch) {
    return urlMatch[0].replace(/[),.]+$/, '');
  }

  const emailMatch = text.match(/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}/i);
  return emailMatch ? `mailto:${emailMatch[0]}` : null;
};

const extractCompanyAndRole = (text) => {
  const cleanedRaw = text.replace(/\*+/g, ' ').replace(/[•🔍]/g, ' ');
  const normalized = cleanedRaw.replace(/\s+/g, ' ').trim();

  const roleLine = cleanedRaw
    .split(/\r?\n/)
    .map((line) => line.trim())
    .find((line) => /^position\s*:/i.test(line));

  const explicitRole = roleLine
    ? roleLine
        .replace(/^position\s*:/i, '')
        .replace(/[|]+$/, '')
        .replace(/\s+/g, ' ')
        .trim()
    : null;

  const atCompanyMatch = normalized.match(/\bat\s+([A-Z][A-Za-z0-9&.\- ]{2,80}?)(?:,\s*we\s+blend|\s+we\s+blend|\.|\s+is\s+inviting|\s+inviting|$)/i);
  const explicitCompany = atCompanyMatch?.[1]?.trim() || null;

  const headingCompanyMatch = normalized.match(/^([A-Z][A-Za-z0-9&.\- ]{2,80}?)\s+[–—-]\s+/);
  const headingCompany = headingCompanyMatch?.[1]?.trim() || null;

  const patterns = [
    /([A-Z][A-Za-z0-9&.\- ]{1,60}?)\s+(?:is hiring|hiring|hiring for|looking for|seeking)\s+(?:an?\s+)?([A-Z][A-Za-z0-9/+\- ]{2,80})/i,
    /(?:internship|opportunity|opening)\s+(?:at|with)\s+([A-Z][A-Za-z0-9&.\- ]{1,60}?).*?\b(?:for|as)\s+(?:an?\s+)?([A-Z][A-Za-z0-9/+\- ]{2,80})/i,
    /([A-Z][A-Za-z0-9&.\- ]{1,60}?)\s+[—\-:]\s*([A-Z][A-Za-z0-9/+\- ]{2,80}(?:Intern|Engineer|Developer|Analyst|Researcher))/i,
  ];

  for (const pattern of patterns) {
    const match = text.match(pattern);
    if (match) {
      return {
        company: match[1].trim(),
        role: match[2].trim(),
      };
    }
  }

  if (explicitCompany || explicitRole) {
    return {
      company: explicitCompany || headingCompany || null,
      role: explicitRole,
    };
  }

  if (headingCompany && /\bintern\b/i.test(normalized)) {
    const headingRoleMatch = normalized.match(/\b([A-Za-z0-9/+\- ]{2,80}\bIntern\b)/i);
    return {
      company: headingCompany,
      role: headingRoleMatch?.[1]?.trim() || null,
    };
  }

  return { company: null, role: null };
};

const normalizeSummaryText = (value) =>
  value
    .replace(/\*+/g, ' ')
    .replace(/[_`~]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();

const firstSentences = (value, maxSentences = 2) => {
  const normalized = normalizeSummaryText(value);
  const sentences = normalized
    .split(/(?<=[.!?])\s+/)
    .map((part) => part.trim())
    .filter(Boolean);

  if (sentences.length === 0) {
    return normalized.slice(0, 220);
  }

  return sentences.slice(0, maxSentences).join(' ');
};

const buildFallbackSummary = (rawText) => {
  const compact = rawText.replace(/\r/g, '').trim();

  const aboutBlockMatch = compact.match(
    /about\s+[A-Za-z0-9&.\- ]+\s*([\s\S]*?)(?:\n\s*note\s*:|\n\s*last\s*date\s*:|https?:\/\/|$)/i,
  );

  if (aboutBlockMatch?.[1]) {
    const summary = firstSentences(aboutBlockMatch[1], 2);
    if (summary) {
      return summary;
    }
  }

  const filteredLines = compact
    .split('\n')
    .map((line) => line.trim())
    .filter((line) => line.length > 0)
    .filter((line) => !/^last\s*date\s*:/i.test(line))
    .filter((line) => !/^https?:\/\//i.test(line))
    .filter((line) => !/^(ashok|srkr\s+corporate\s+relations)/i.test(line));

  return firstSentences(filteredLines.join(' '), 2);
};

const fallbackExtractOpportunity = (rawText) => {
  const { company, role } = extractCompanyAndRole(rawText);

  return {
    company,
    role,
    category: inferCategory(rawText),
    summary: buildFallbackSummary(rawText) || null,
    deadline: extractDeadlineFromText(rawText),
    apply_link: extractApplyLink(rawText),
  };
};

const callGemini = async (rawText, apiKey) => {
  const prompt = buildPrompt(rawText);
  let lastErrorMessage = 'All Gemini model attempts failed';

  for (const model of GEMINI_MODELS) {
    try {
      const response = await axios.post(
        `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`,
        {
          contents: [
            {
              parts: [{ text: prompt }],
            },
          ],
          generationConfig: {
            temperature: 0.1,
          },
        },
        {
          headers: {
            'Content-Type': 'application/json',
          },
          timeout: 30000,
        },
      );

      const generatedText = response?.data?.candidates?.[0]?.content?.parts?.[0]?.text;
      if (!generatedText) {
        throw new Error('No response received from Gemini API');
      }

      return sanitizeGeminiJson(generatedText);
    } catch (error) {
      lastErrorMessage = error?.response?.data?.error?.message || error.message;
      console.error(`[Gemini] Model ${model} failed: ${lastErrorMessage}`);
    }
  }

  throw new Error(lastErrorMessage);
};

/**
 * Extract structured internship information from raw text using Gemini API.
 * Throws if Gemini is unavailable or fails — callers must handle fallback explicitly.
 * @param {string} rawText - Raw notification text to process
 * @returns {Promise<Object>} Structured opportunity data
 */
const extractOpportunityFromText = async (rawText) => {
  const apiKey = process.env.GEMINI_API_KEY;

  if (!apiKey) {
    console.error('[Gemini] GEMINI_API_KEY is not set in environment.');
    throw new Error('GEMINI_API_KEY missing');
  }

  const extractedData = await callGemini(rawText, apiKey);
  const fallbackData = fallbackExtractOpportunity(rawText);

  return {
    company: extractedData.company || fallbackData.company,
    role: extractedData.role || fallbackData.role,
    category: extractedData.category || fallbackData.category,
    summary: extractedData.summary || fallbackData.summary,
    deadline: normalizeDeadline(extractedData.deadline) || fallbackData.deadline,
    apply_link: extractedData.apply_link || fallbackData.apply_link,
  };
};

/**
 * Use Gemini to decide if an email is actually about an internship/job opportunity.
 * Filters out promotions, newsletters, ads, and other trash.
 * Returns true (relevant) on any Gemini error so emails are not lost silently.
 * @param {string} emailText - Combined subject + body of the email
 * @returns {Promise<boolean>}
 */
const isEmailRelevantToInternship = async (emailText) => {
  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) {
    return true; // No Gemini key → let everything through
  }

  const prompt = buildRelevancePrompt(emailText);

  for (const model of GEMINI_MODELS) {
    try {
      const response = await axios.post(
        `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`,
        {
          contents: [{ parts: [{ text: prompt }] }],
          generationConfig: { temperature: 0.0, maxOutputTokens: 10 },
        },
        { headers: { 'Content-Type': 'application/json' }, timeout: 30000 },
      );

      const text = response?.data?.candidates?.[0]?.content?.parts?.[0]?.text || '';
      return text.trim().toUpperCase().startsWith('YES');
    } catch (_err) {
      // Try next model
    }
  }

  return true; // On all failures, let email through
};

module.exports = {
  extractOpportunityFromText,
  isEmailRelevantToInternship,
};
