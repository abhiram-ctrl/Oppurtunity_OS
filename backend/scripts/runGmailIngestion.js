const path = require('path');
const mongoose = require('mongoose');

require('dotenv').config({
  path: path.join(__dirname, '..', '.env'),
  quiet: true,
});

const connectDB = require('../config/db');
const { processRecentOpportunityEmails } = require('../services/gmailService');

const run = async () => {
  try {
    await connectDB();

    const result = await processRecentOpportunityEmails({
      credentialsPath: path.join(__dirname, '..', 'config', 'credentials.json'),
      tokenPath: path.join(__dirname, '..', 'config', 'token.json'),
      maxResults: Number(process.env.GMAIL_MAX_RESULTS || 20),
    });

    console.log('📊 Gmail ingestion summary:', result);
  } catch (error) {
    console.error('❌ Gmail ingestion failed:', error.message);
    process.exitCode = 1;
  } finally {
    try {
      await mongoose.connection.close();
    } catch (closeError) {
      // Ignore close errors to avoid masking original failure.
    }
  }
};

run();
