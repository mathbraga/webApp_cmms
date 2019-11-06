const express = require('express');
const router = express.Router();
const multer  = require('multer');
const { multerConfig } = require('../configs');
const storage = multer.diskStorage(multerConfig.diskStorage);
const upload = multer({ storage: storage });

router.post(
  '/',
  upload.fields(multerConfig.fields),
  (req, res, next) => {
    // console.log(req.files);
    // console.log(req.body);
    // res.json({message: 'Você fez upload.'});
    
    // Use next() if more backend operations are necessary
    next();
  }
);

module.exports = router;

