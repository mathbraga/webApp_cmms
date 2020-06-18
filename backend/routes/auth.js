const router = require('express').Router();
const passport = require('../middlewares/passport');
const paths = require('../paths');

router.post(
  paths.login,
  passport.authenticate('local'),
  (req, res) => {
    if(req.user){
      // console.log(req.user)
      let cookieContent = req.user.personId.toString() + '-' + req.user.role;
      // console.log(cookieContent)
      res.cookie('cmms:user', cookieContent);
      res.json(req.user);
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
