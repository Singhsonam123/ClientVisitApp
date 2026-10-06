const mongoose = require('mongoose');

const voteSchema = new mongoose.Schema(
  {
    employeeId:  { type: String, required: true, unique: true }, // one vote per employee
    candidateId: { type: String, required: true },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Vote', voteSchema);