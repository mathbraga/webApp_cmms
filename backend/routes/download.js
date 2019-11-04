const express = require('express');
const router = express.Router();
const paths = require('../paths');

router.get(paths.filename, (req, res) => {
  res.sendFile(process.env.PWD + '/files/touch.txt');
});

module.exports = router;
