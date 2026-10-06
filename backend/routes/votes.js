const express = require('express');
const Vote    = require('../models/Vote');

const router = express.Router();

// ── GET /api/votes ────────────────────────────────────────────────────────────
// Returns aggregated vote counts per candidate.
router.get('/', async (req, res) => {
  try {
    const counts = await Vote.aggregate([
      { $group: { _id: '$candidateId', voteCount: { $sum: 1 } } },
    ]);
    // Convert to { candidateId: count } map
    const result = {};
    counts.forEach((c) => { result[c._id] = c.voteCount; });
    res.json({ success: true, voteCounts: result });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// ── GET /api/votes/check/:employeeId ─────────────────────────────────────────
// Returns the candidateId the employee voted for, or null.
router.get('/check/:employeeId', async (req, res) => {
  try {
    const vote = await Vote.findOne({ employeeId: req.params.employeeId });
    res.json({ success: true, votedFor: vote ? vote.candidateId : null });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// ── POST /api/votes/cast ──────────────────────────────────────────────────────
// Body: { employeeId, candidateId }
// One vote per employee — returns 409 if already voted.
router.post('/cast', async (req, res) => {
  try {
    const { employeeId, candidateId } = req.body;
    if (!employeeId || !candidateId) {
      return res.status(400).json({ success: false, message: 'Missing employeeId or candidateId' });
    }

    const existing = await Vote.findOne({ employeeId });
    if (existing) {
      return res.status(409).json({
        success: false,
        message: 'You have already cast your vote!',
        votedFor: existing.candidateId,
      });
    }

    const vote = await Vote.create({ employeeId, candidateId });

    // Return updated counts
    const counts = await Vote.aggregate([
      { $group: { _id: '$candidateId', voteCount: { $sum: 1 } } },
    ]);
    const voteCounts = {};
    counts.forEach((c) => { voteCounts[c._id] = c.voteCount; });

    res.status(201).json({ success: true, vote, voteCounts });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

module.exports = router;