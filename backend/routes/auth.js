const express = require('express');
const bcrypt  = require('bcryptjs');
const User    = require('../models/User');

const router = express.Router();

// POST /api/auth/signup
router.post('/signup', async (req, res) => {
  try {
    const { firstName, lastName, email, password } = req.body;

    if (!firstName || !lastName || !email || !password) {
      return res.status(400).json({ error: 'All fields are required.' });
    }

    const existing = await User.findOne({ email: email.toLowerCase() });
    if (existing) {
      return res.status(409).json({ error: 'Email is already registered.' });
    }

    const hashed = await bcrypt.hash(password, 10);
    const user   = await User.create({ firstName, lastName, email, password: hashed });

    res.status(201).json({
      _id:        user._id.toString(),
      firstName:  user.firstName,
      lastName:   user.lastName,
      email:      user.email,
      department: user.department,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/auth/login
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required.' });
    }

    const user = await User.findOne({ email: email.toLowerCase() });
    if (!user) {
      return res.status(401).json({ error: 'Invalid email or password.' });
    }

    const match = await bcrypt.compare(password, user.password);
    if (!match) {
      return res.status(401).json({ error: 'Invalid email or password.' });
    }

    res.json({
      _id:        user._id.toString(),
      firstName:  user.firstName,
      lastName:   user.lastName,
      email:      user.email,
      department: user.department,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;