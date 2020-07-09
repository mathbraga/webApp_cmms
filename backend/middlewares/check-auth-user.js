const checkAuthUser = (req, res, next) => {
  if (!req.user) {
    // res.sendFile has to be commented for db connection to work in frontend testing
    // res.sendFile(path.join(__dirname, '../public/login/login.html'));
    // res.redirect('/login.html');
    console.log('no user')
    next();
  } else {
    // res.send('User connected.');
    console.log('yes user')
    next();
  }
}

module.exports = checkAuthUser;
