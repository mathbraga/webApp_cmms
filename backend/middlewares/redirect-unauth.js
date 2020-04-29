const redirectUnauth = (req, res, next) => {
  if (!req.user) {
    // res.status(404).end();
    next();
  } else {
    next();
  }
}

module.exports = redirectUnauth;