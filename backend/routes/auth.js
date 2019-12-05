const router = require('express').Router();
const passport = require('../middlewares/passport');
const paths = require('../paths');

router.post(paths.login,
  passport.authenticate('local'),
  (req, res) => {
    res.cookie('cmms:user', req.user);
    res.json({'response': 'Login succeeded'});
});

router.get(paths.logout, (req, res) => {
  req.logout();
  req.session = null;
  res.json({'logout': 'logged out'})
});

module.exports = router;
