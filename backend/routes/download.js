const express = require('express');
const router = express.Router();

router.get('/:filename', (req, res) => {
  res.sendFile(process.env.PWD + '/files/touch.txt');
});

module.exports = router;
