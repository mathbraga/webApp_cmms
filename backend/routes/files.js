const express = require('express');
const router = express.Router();

router.get('/:filename', (req, res) => {
  res.sendFile('/home/hzlopes/repositories/cmms/backend/files/touch.txt');
});

module.exports = router;
