const fs = require('fs');
const express = require('express');
const router = express.Router();

router.post('/', (req, res) => {
  fs.writeFile('uploaded.jpeg', data, err => {
    if(err) console.log(err);
    console.log('ok, file saved.')
  });
});


module.exports = router;

