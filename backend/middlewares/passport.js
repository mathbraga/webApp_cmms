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
      data = await db.query('select api.authenticate($1, $2)', [email, password]);
      if (data.rows.length === 0) {
        return done(null, false, {message: 'Incorrect'});
      }
    } catch (error) {
      return done(error);
    }
    let userData = data.rows[0].authenticate;
    return done(null, userData);
  }
));

passport.serializeUser((userData, done) => {
  done(null, userData);
});

passport.deserializeUser(async (userData, done) => {
  try {
    let data = await db.query('select person_id from persons where person_id = $1', [parseInt(userData.split('-')[0],10)]);
    if (data.rows.length === 0){
      return done(new Error('user not found'));
    }
    done(null, data.rows[0].person_id);
  } catch (error) {
    done(error);
  }
});



module.exports = passport;
