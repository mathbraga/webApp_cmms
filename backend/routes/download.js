const express = require('express');
const router = express.Router();
const paths = require('../paths');
const path = require('path');

router.get(paths.fileuuid, (req, res, next) => {
  res.sendFile(
    path.join(
      process.cwd(),
      paths.download,
      req.path
    )
  )
});

module.exports = router;
