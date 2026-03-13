const cron = require('node-cron');
const mongoose = require('mongoose');
const Opportunity = require('../models/Opportunity');

const ONE_DAY_MS = 1000 * 60 * 60 * 24;

const getDaysLeft = (deadline) => {
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  const deadlineDate = new Date(deadline);
  deadlineDate.setHours(0, 0, 0, 0);

  return Math.ceil((deadlineDate.getTime() - today.getTime()) / ONE_DAY_MS);
};

const checkDeadlineReminders = async () => {
  try {
    if (mongoose.connection.readyState !== 1) {
      console.warn('Reminder job skipped: MongoDB is not connected yet.');
      return;
    }

    const opportunities = await Opportunity.find({}, { company: 1, role: 1, deadline: 1 }).lean();

    opportunities.forEach((opportunity) => {
      const daysLeft = getDaysLeft(opportunity.deadline);

      if (daysLeft >= 0 && daysLeft <= 3) {
        console.log(`⚠ ${daysLeft} days left to apply for ${opportunity.company} ${opportunity.role}`);
      }
    });
  } catch (error) {
    console.error('Reminder job failed:', error.message);
  }
};

const startReminderService = () => {
  // 🎯 HACKATHON DEMO: Change '0 18 * * *' to test at a specific minute.
  // Format: 'MINUTE HOUR * * *'  e.g. '30 14 * * *' = 2:30 PM
  cron.schedule('0 18 * * *', async () => {
    await checkDeadlineReminders();
  });

  console.log('Deadline reminder cron started (runs daily at 6:00 PM).');
};

module.exports = {
  startReminderService,
};
