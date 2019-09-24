const express = require('express');
const router = express.Router();
const passport = require('passport');
const LocalStrategy = require('passport-local').Strategy;
const client = require('../pgclient');

client.connect();

passport.use(new LocalStrategy(
  {
    usernameField: 'email',
    passwordField: 'password'
  },
  async function(email, password, done){
    // console.log('inside passport.use')
    let data;
    try {
      data = await client.query('SELECT authenticate($1, $2)', [email, password]);
      if (data.rows.length === 0) {
        return done(null, false, {message: 'Incorrect'});
      }
    } catch (error) {
      return done(error);
    }
    // console.log('user::: ' + JSON.stringify(user));
    let userId = data.rows[0].authenticate;
    return done(null, userId);
  }
));

passport.serializeUser((userId, done) => {
  console.log('\nSERIALIZATION\n')
  console.log(userId)
  done(null, userId);
});

passport.deserializeUser(async (userId, done) => {
  console.log('\nDESERIALIZATION\n')
  try {
    let data = await client.query('SELECT person_id FROM persons WHERE person_id = $1', [userId]);
    if (data.rows.length === 0){
      return done(new Error('user not found'));
    }
    // console.log(JSON.stringify(data))
    done(null, data.rows[0].person_id);
  } catch (error) {
    done(error);
  }
});

router.post('/login',
  passport.authenticate('local'),
  function(req, res){
    console.log('req session '+ JSON.stringify(req.session))
    console.log('req user '+ JSON.stringify(req.user))
    res.cookie('cmms:user', req.user.toString());
    res.json({'response': 'Login succeeded'});
});

router.get('/logout', function(req, res){
  console.log('\nINSIDE LOGOUT\n');
  console.log('req.session BEFORE: ' + JSON.stringify(req.session));
  console.log('req.user BEFORE: ' + JSON.stringify(req.user));
  req.logout();
  req.session = null;
  console.log('req.session AFTER: ' + JSON.stringify(req.session));
  console.log('req.user AFTER: ' + JSON.stringify(req.user));
  res.json({'logout': 'logged out'})
});

module.exports = router;
