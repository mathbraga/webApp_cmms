const router = require('express').Router();
const paths = require('../paths');

router.get(
  paths.cookieAuth,
  (req, res) => {
    if (req.user) {
      res.json(req.cookies);
    }
    else{
      res.json({ cookies: false });
    }
  }
)

module.exports = router;