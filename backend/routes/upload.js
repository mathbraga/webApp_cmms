const express = require('express');
const router = express.Router();
const multer  = require('multer');
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    
    /* Example of file:
      {
        fieldname: 'avatar',
        originalname: 'originalnamefromfrontend.jpeg',
        encoding: '7bit',
        mimetype: 'image/jpeg'
      }
    */

  // console.log(file);
  let folder = 'files/'
    if(file.fieldname === 'image'){
      folder = 'public/images';
    }
    cb(null, folder);
  },
  filename: function (req, file, cb) {
    cb(null, file.originalname);
  }
});
const upload = multer({ storage: storage });

router.post(
  '/',
  upload.fields(
    [
      { name: 'image', maxCount: 1 },
      { name: 'files', maxCount: 10 },
    ]
  ),
  (req, res, next) => {
    // console.log(req.files);
    // console.log(req.body);
    res.json({message: 'Você fez upload.'});
    
    // Use next() if more backend operations are necessary
    // next();
  }
);

module.exports = router;

