const passport = require('passport');
const LocalStrategy = require('passport-local').Strategy;
const db = require('../db');

passport.use(new LocalStrategy(
  {
    usernameField: 'email',
    passwordField: 'password'
  },
  async function(email, password, done){
    let data;
    try {
      data = await db.query('select ws.authenticate($1, $2)', [email, password]);
      if (data.rows.length === 0) {
        return done(null, false, {message: 'Incorrect'});
      }
    } catch (error) {
      return done(error);
    }
<<<<<<< HEAD
    let userData = data.rows[0].authenticate;
    
    return done(null, userData);
=======
    let user = data.rows[0].authenticate;
    // console.log(user);

    // user will become req.user (this is done by passportjs)
    // user will be accessible in auth route (/auth/login)
    return done(null, user);
>>>>>>> bba61117e75c201f6de657cceab366c166e10fee
  }
));

passport.serializeUser((user, done) => {
  let serializedUser = user.personId.toString() + '-' + user.role;
  done(null, serializedUser);
});

passport.deserializeUser(async (serializedUser, done) => {
  done(null, serializedUser);
});



module.exports = passport;
