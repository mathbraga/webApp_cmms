const router = require('express').Router();
const passport = require('../middlewares/passport');
const paths = require('../paths');
const jwt = require('jsonwebtoken');

router.post(
  paths.login,
  passport.authenticate('local'),
  (req, res) => {
    if(req.user){
      // console.log(req.user)
      // let cookieContent = req.user.personId.toString() + '-' + req.user.role;
      // console.log(cookieContent)
      // res.cookie('cmms:user', cookieContent);
      res.json(req.user);
    }
  }
);

router.get(
  paths.logout,
  (req, res) => {
    // const tokenHeader = req.headers['authorization'];
    // const token = tokenHeader && tokenHeader.split(' ')[1];

    // if(token == null){
    //   return res.sendStatus(401);
    // }

    // jwt.verify(token, process.env.ACCESS_TOKEN, (err, user) => {
    //   if (err) {
    //     return res.sendStatus(403);
    //   }
    //   return console.log('Valid token user: ' + user.user);
    // })
    req.logout();
    req.session = null;
    res.json({ logoutSuccess: true });
  }
);

module.exports = router;
