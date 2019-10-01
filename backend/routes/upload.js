const express = require('express');
const router = express.Router();
const multer  = require('multer');
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/');
  },
  filename: function (req, file, cb) {
    cb(null, file.originalname);
  }
});
const upload = multer({ storage: storage })

router.post('/', upload.single('photo'), (req, res, next) => {
  console.log(req.file);
  res.json({message: 'Você fez upload.'});
  // Use next() if more backend operations are necessary
  // next();
});

module.exports = router;

