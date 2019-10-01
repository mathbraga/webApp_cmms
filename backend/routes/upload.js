const fs = require('fs');
const express = require('express');
const router = express.Router();

router.post('/', (req, res) => {
  
  console.log(req.body);

  // const buf = new Buffer(req.body);
  
  fs.writeFile('uploaded.jpg', req.body, err => {
    if(err) console.log(err);
    console.log('ok, file saved.')
  });
});


module.exports = router;

