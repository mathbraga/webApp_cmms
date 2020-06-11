const router = require('express').Router();
const passport = require('../middlewares/passport');
const paths = require('../paths');
// const jwt = require('jsonwebtoken');

router.post(
  paths.login,
  passport.authenticate('local'),
  (req, res) => {
    if(req.user){
      // const token = jwt.sign({ user: req.user }, process.env.ACCESS_TOKEN, { expiresIn: '15s' })
      res.cookie('cmms:user', req.user);
      res.json({ loginSuccess: true });
      // res.json({ loginSuccess: true, token: token });
    } else {
      res.json({ loginSuccess: false })
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
