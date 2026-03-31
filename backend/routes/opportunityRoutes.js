const express = require('express');
const { getOpportunities, importNotification, deleteOpportunity } = require('../controllers/opportunityController');

const router = express.Router();

router.get('/opportunities', getOpportunities);
router.post('/import-notification', importNotification);
router.delete('/opportunities/:id', deleteOpportunity);

module.exports = router;
