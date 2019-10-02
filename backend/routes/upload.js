const express = require('express');
const router = express.Router();
const multer  = require('multer');
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'public/files/');
  },
  filename: function (req, file, cb) {
    cb(null, file.originalname);
  }
});
const upload = multer({ storage: storage });

router.post('/', upload.array('files[]'), (req, res, next) => {
  // console.log(req.files);
  // console.log(req.body);
  // res.json({message: 'Você fez upload.'});
  // Use next() if more backend operations are necessary
  next();
});

module.exports = router;

