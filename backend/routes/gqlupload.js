const express = require('express');
const router = express.Router();
const { graphqlUploadExpress } = require('graphql-upload');

router.post('/', graphqlUploadExpress({
  // maxFieldSize: ,
  maxFileSize: 10000000,
  maxFiles: 10,
}));

module.exports = router;

