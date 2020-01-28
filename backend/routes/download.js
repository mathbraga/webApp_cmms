const express = require('express');
const router = express.Router();
const paths = require('../paths');
const path = require('path');

router.get(paths.fileuuid, (req, res, next) => {
  
  const [emptyString, uuid, filename] = req.path.split('/');

  // console.log(req.path)

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
