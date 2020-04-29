const redirectUnauth = (req, res, next) => {
  if (!req.user) {
    // res.status(401).end();
    next();
  } else {
    next();
  }
}

module.exports = redirectUnauth;