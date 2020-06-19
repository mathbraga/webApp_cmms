<<<<<<< HEAD:backend/middlewares/redirect-unauth.js
const path = require('path');

const redirectUnauth = (req, res, next) => {
=======
const checkAuthUser = (req, res, next) => {
>>>>>>> bba61117e75c201f6de657cceab366c166e10fee:backend/middlewares/check-auth-user.js
  if (!req.user) {
    // res.sendFile has to be commented for db connection to work in frontend testing
    // res.sendFile(path.join(__dirname, '../public/login/login.html'));
    // res.redirect('/login.html');
    next();
  } else {
    // res.send('User connected.');
    next();
  }
}

module.exports = checkAuthUser;
