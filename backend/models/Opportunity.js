const mongoose = require('mongoose');

const opportunitySchema = new mongoose.Schema(
  {
    company: {
      type: String,
      required: true,
      trim: true,
    },
    role: {
      type: String,
      required: true,
      trim: true,
    },
    category: {
      type: String,
      required: true,
      trim: true,
    },
    summary: {
      type: String,
      required: true,
      trim: true,
    },
    deadline: {
      type: Date,
      required: true,
    },
    apply_link: {
      type: String,
      required: true,
      trim: true,
    },
    messageHash: {
      type: String,
      trim: true,
      index: true,
    },
    contentHash: {
      type: String,
      trim: true,
      index: true,
    },
    rawMessage: {
      type: String,
      trim: true,
      default: '',
    },
    sourceTitle: {
      type: String,
      trim: true,
      default: '',
    },
    sources: {
      type: [String],
      default: [],
    },
  },
  {
    timestamps: { createdAt: true, updatedAt: false },
  }
);

module.exports = mongoose.model('Opportunity', opportunitySchema);
