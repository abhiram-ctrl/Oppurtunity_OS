const fs = require('fs');
const path = require('path');
const cron = require('node-cron');

const startGmailPollingService = () => {
  const credentialsPath = path.join(__dirname, '..', 'config', 'credentials.json');
  const tokenPath = path.join(__dirname, '..', 'config', 'token.json');

  if (!fs.existsSync(credentialsPath)) {
    console.warn('⚠️  Gmail credentials not found. Skipping Gmail polling service.');
    return null;
  }

  if (!fs.existsSync(tokenPath)) {
    console.warn('⚠️  Gmail token not found. To enable Gmail polling:');
    console.warn('    1. Run:  node scripts/gmailAuthSetup.js');
    console.warn('    2. Follow the browser auth flow and paste the code.');
    console.warn('    3. Restart the server.');
    return null;
  }

  // Only require gmailService (which loads googleapis) when credentials exist.
  let processRecentOpportunityEmails;
  try {
    ({ processRecentOpportunityEmails } = require('./gmailService'));
  } catch (err) {
    console.error('❌ Failed to load Gmail service — is googleapis installed? Run: npm install');
    console.error('   Error:', err.message);
    return null;
  }

  const task = cron.schedule('*/5 * * * *', async () => {
    console.log('📧 Checking Gmail for opportunities...');

    try {
      const result = await processRecentOpportunityEmails({
        maxResults: Number(process.env.GMAIL_MAX_RESULTS || 10),
      });

      console.log(
        `✅ Gmail polling complete. fetched=${result.totalFetched} saved=${result.saved} duplicate=${result.duplicates} skipped=${result.skipped}`,
      );
    } catch (error) {
      console.error('❌ Gmail polling failed:', error.message);
    }
  });

  console.log('📧 Gmail polling service started (runs every 5 minutes).');
  return task;
};

module.exports = {
  startGmailPollingService,
};