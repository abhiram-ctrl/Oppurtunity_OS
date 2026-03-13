const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env'), quiet: true });
const express = require('express');
const cors = require('cors');
const connectDB = require('./config/db');
const opportunityRoutes = require('./routes/opportunityRoutes');
const { startReminderService } = require('./services/reminderService');
const { startGmailPollingService } = require('./services/gmailPollingService');

const app = express();
const PORT = process.env.PORT || 5000;

connectDB();
startReminderService();
startGmailPollingService();

app.use(cors());
app.use(express.json());
app.use('/', opportunityRoutes);

app.get('/test', (req, res) => {
	res.status(200).json({ message: 'Backend running successfully' });
});

app.listen(PORT, '0.0.0.0', () => {
	console.log(`Server is running on http://0.0.0.0:${PORT} (accessible via your PC IP)`);
});
