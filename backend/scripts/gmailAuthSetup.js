const fs = require('fs');
const path = require('path');
const readline = require('readline');
const { google } = require('googleapis');

const SCOPES = ['https://www.googleapis.com/auth/gmail.readonly'];

const CREDENTIALS_PATH = path.join(__dirname, '..', 'config', 'credentials.json');
const TOKEN_PATH = path.join(__dirname, '..', 'config', 'token.json');

const askQuestion = (query) =>
  new Promise((resolve) => {
    const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
    rl.question(query, (answer) => {
      rl.close();
      resolve(answer);
    });
  });

const loadOAuthClient = () => {
  if (!fs.existsSync(CREDENTIALS_PATH)) {
    throw new Error(`Missing credentials file: ${CREDENTIALS_PATH}`);
  }

  const credentials = JSON.parse(fs.readFileSync(CREDENTIALS_PATH, 'utf8'));
  const config = credentials.installed || credentials.web;

  if (!config) {
    throw new Error('credentials.json must contain installed or web config');
  }

  return new google.auth.OAuth2(
    config.client_id,
    config.client_secret,
    config.redirect_uris?.[0],
  );
};

const run = async () => {
  try {
    const oauth2Client = loadOAuthClient();

    const authUrl = oauth2Client.generateAuthUrl({
      access_type: 'offline',
      scope: SCOPES,
      prompt: 'consent',
    });

    console.log('\nOpen this URL in your browser and allow access:\n');
    console.log(authUrl);

    const code = await askQuestion('\nPaste the authorization code here: ');

    const { tokens } = await oauth2Client.getToken(code.trim());
    oauth2Client.setCredentials(tokens);

    fs.writeFileSync(TOKEN_PATH, JSON.stringify(tokens, null, 2));
    console.log(`\n✅ Token saved to ${TOKEN_PATH}`);
  } catch (error) {
    console.error('❌ OAuth setup failed:', error.message);
    process.exitCode = 1;
  }
};

run();
