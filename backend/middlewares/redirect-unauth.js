const path = require('path');

const redirectUnauth = (req, res, next) => {
  if (!req.user) {
    res.sendFile(path.join(__dirname, '../public/html/login.html'))
  } else {
    next();
  }
}

module.exports = redirectUnauth;