const express = require('express');
const router = express.Router();
const passport = require('passport');
const LocalStrategy = require('passport-local').Strategy;
const { Client } = require('pg');

const client = new Client({
  user: process.env.DB_ADMIN,
  host: process.env.DB_HOST,
  database: process.env.DB_DBNAME,
  password: process.env.DB_PASS,
  port: process.env.DB_PORT,
});

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
    done(null, data.rows[0]);
  } catch (error) {
    done(error);
  }
});

router.post('/',
  passport.authenticate('local'),
  function(req, res){
    console.log('req session '+ JSON.stringify(req.session))
    console.log('req user '+ JSON.stringify(req.user))
    res.cookie('cmms:user', req.user.toString());
    res.json({'response': 'Login succeeded'});
});

module.exports = router;
