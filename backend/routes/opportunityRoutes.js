const express = require('express');
const { getOpportunities, importNotification } = require('../controllers/opportunityController');

const router = express.Router();

router.get('/opportunities', getOpportunities);
router.post('/import-notification', importNotification);

module.exports = router;
