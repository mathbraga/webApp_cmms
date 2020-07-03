const express = require('express');
const router = express.Router();
const paths = require('../paths');
const path = require('path');

router.get(
  '/',
  (req, res, next) => {

  // console.log(req.query);

  const { uuid, filename } = req.query;

  res.download(
    path.join(
      process.cwd(),
      paths.files,
      uuid
    ),
    filename
  )
});

module.exports = router;
