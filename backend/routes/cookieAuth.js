const router = require('express').Router();
const fetchUserData = require('../utils/fetchUserData');

router.get(
  '/',
  (req, res) => {
    if(req.user){
      if(req.cookies){
          const roleInfo = req.user;
          const roleParams = roleInfo.split('-');
          fetchUserData(roleParams[0], roleParams[1])
          .then(r => res.json(r));
        }
    }
    else{
      res.sendStatus(400);
    }
  }
)

module.exports = router;