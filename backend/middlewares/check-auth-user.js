const checkAuthUser = (req, res, next) => {
  if (!req.user) {
    // res.sendFile has to be commented for db connection to work in frontend testing
    // res.sendFile(path.join(__dirname, '../public/login/login.html'));
    // res.redirect('/login.html');
    next();
  } else {
    // res.send('User connected.');
    // res.json(req.cookies);
    next();
  }
}

module.exports = checkAuthUser;
