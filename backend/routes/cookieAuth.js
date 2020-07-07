const router = require('express').Router();

router.get(
  '/',
  (req, res) => {
    if(req.user){
      if(req.cookies){
        res.json({ cookie: true });
      }
    }
    else{
      res.sendStatus(400);
    }
  }
)

module.exports = router;