const express = require('express');
const router = express.Router();

router.get('/', function(req, res){
  console.log('\nINSIDE LOGOUT\n');
  console.log('req.session BEFORE: ' + JSON.stringify(req.session));
  console.log('req.user BEFORE: ' + JSON.stringify(req.user));
  req.logout();
  req.session = null;
  console.log('req.session AFTER: ' + JSON.stringify(req.session));
  console.log('req.user AFTER: ' + JSON.stringify(req.user));
  res.json({'logout': 'logged out'})
});

module.exports = router;