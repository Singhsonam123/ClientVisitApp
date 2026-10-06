const express = require('express');
const multer  = require('multer');
const path    = require('path');
const { v4: uuidv4 } = require('uuid');
const Photo   = require('../models/Photo');

const router = express.Router();

// ── Multer storage config ────────────────────────────────────────────────────
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, path.join(__dirname, '../uploads'));
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname) || '.jpg';
    cb(null, `${uuidv4()}${ext}`);
  },
});

const upload = multer({
  storage,
  limits: { fileSize: 10 * 1024 * 1024 }, // 10 MB
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) cb(null, true);
    else cb(new Error('Only image files are allowed'));
  },
});

// ── GET /api/gallery ─────────────────────────────────────────────────────────
// Returns all photos sorted newest first.
// Optional query: ?employeeId=xxx  or  ?dayLabel=Day+1
router.get('/', async (req, res) => {
  try {
    const filter = {};
    if (req.query.employeeId) filter.employeeId = req.query.employeeId;
    if (req.query.dayLabel)   filter.dayLabel   = req.query.dayLabel;

    const photos = await Photo.find(filter).sort({ createdAt: -1 });
    res.json({ success: true, photos });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// ── POST /api/gallery/upload ─────────────────────────────────────────────────
// Accepts multipart/form-data with fields:
//   image (file), employeeId, employeeName, caption, dayLabel
router.post('/upload', upload.single('image'), async (req, res) => {
  try {
    const { employeeId, employeeName, caption, dayLabel } = req.body;

    if (!req.file) {
      return res.status(400).json({ success: false, message: 'No image file provided' });
    }
    if (!employeeId || !employeeName || !dayLabel) {
      return res.status(400).json({ success: false, message: 'Missing required fields' });
    }

    const baseUrl = `${req.protocol}://${req.get('host')}`;
    const imageUrl = `${baseUrl}/uploads/${req.file.filename}`;

    const photo = await Photo.create({
      employeeId,
      employeeName,
      imagePath: req.file.path,
      imageUrl,
      caption: caption || '',
      dayLabel,
    });

    res.status(201).json({ success: true, photo });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// ── DELETE /api/gallery/:id ───────────────────────────────────────────────────
router.delete('/:id', async (req, res) => {
  try {
    const photo = await Photo.findByIdAndDelete(req.params.id);
    if (!photo) return res.status(404).json({ success: false, message: 'Photo not found' });
    res.json({ success: true, message: 'Photo deleted' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

module.exports = router;