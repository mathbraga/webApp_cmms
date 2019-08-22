const express = require('express');
const router = express.Router();
const passport = require('passport');
const LocalStrategy = require('passport-local').Strategy;
const { Client } = require('pg');

const client = new Client({
  user: 'postgres',
  host: '172.30.49.152',
  database: 'cmms',
  password: '123456',
  port: 5432,
});

client.connect();

passport.use(new LocalStrategy(  
  async function(username, password, done){
    // console.log('inside passport.use')
    let user;
    try {
      data = await client.query('SELECT public.autenticar($1, $2)', [username, password]);
      if (data.rows.length === 0) {
        return done(null, false, {message: 'Incorrect'});
      }
    } catch (error) {
      return done(error);
    }
    // console.log('user::: ' + JSON.stringify(user));
    let userId = data.rows[0].autenticar;
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
    let data = await client.query('SELECT id FROM users WHERE id = $1', [userId]);
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
    res.cookie('cookiename', req.user.toString());

    // console.log(res.get('set-cookie'))

    res.json({'response': 'response from login'});
});

module.exports = router;
