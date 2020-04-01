const router = require('express').Router();
const passport = require('../middlewares/passport');
const paths = require('../paths');

router.post(
  paths.login,
  passport.authenticate('local'),
  (req, res) => {
    if(req.user){
      res.cookie('cmms:user', req.user);
      res.json({ loginSuccess: true });
    } else {
      res.json({ loginSuccess: false })
    }
  }
);

router.get(
  paths.logout,
  (req, res) => {
    req.logout();
    req.session = null;
    res.json({ logoutSuccess: true });
  }
);

module.exports = router;
