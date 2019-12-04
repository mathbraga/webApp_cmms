const router = require('express').Router();
const passport = require('../middlewares/passport');
const paths = require('../paths');

router.post(paths.login,
  passport.authenticate('local'),
  function(req, res){
    console.log('req session '+ JSON.stringify(req.session))
    console.log('req user '+ JSON.stringify(req.user))
    res.cookie('cmms:user', req.user);
    res.json({'response': 'Login succeeded'});
});

router.get(paths.logout, function(req, res){
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
