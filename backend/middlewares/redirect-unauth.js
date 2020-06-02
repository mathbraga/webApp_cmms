const path = require('path');

const redirectUnauth = (req, res, next) => {
  if (!req.user) {
    // res.sendFile(path.join(__dirname, '../public/login/login.html'));
    next();
  } else {
    // res.send('User connected.');
    next();
  }
}

module.exports = redirectUnauth;