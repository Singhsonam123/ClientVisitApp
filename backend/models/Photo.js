const mongoose = require('mongoose');

const photoSchema = new mongoose.Schema(
  {
    employeeId:   { type: String, required: true, index: true },
    employeeName: { type: String, required: true },
    imagePath:    { type: String, required: true },   // server-relative path
    imageUrl:     { type: String, required: true },   // full URL served to clients
    caption:      { type: String, default: '' },
    dayLabel:     { type: String, required: true },   // 'Day 1' | 'Day 2' | 'Day 3'
  },
  { timestamps: true }
);

module.exports = mongoose.model('Photo', photoSchema);