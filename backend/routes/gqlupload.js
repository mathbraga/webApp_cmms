const express = require('express');
const router = express.Router();
const { graphqlUploadExpress } = require('graphql-upload');

router.post(
  '/',
  graphqlUploadExpress({
    // maxFileSize: 10000000,
    maxFiles: 10
  }),
  (req, res, next) => {
    console.log('INSIDE GQL UPLOAD ROUTE');
    // console.log(req.body);
    // res.json({message: 'Você fez upload.'});
    
    // Use next() if more backend operations are necessary
    next();
  }
);

module.exports = router;

