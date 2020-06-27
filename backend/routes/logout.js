const router = require('express').Router();
const paths = require('../paths');

router.get(
  '/',
  (req, res) => {
    req.logout();
    req.session = null;
    res.json({ logoutSuccess: true });
  }
);

module.exports = router;
