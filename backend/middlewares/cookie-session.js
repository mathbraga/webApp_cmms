const cookieSession = require('cookie-session');

module.exports = cookieSession({
  name: 'cmms:session',
  keys: ['key0', 'key1', 'key2'],
  // secret: ,
  maxAge: 604800000, // miliseconds in 1 week
  // expires: ,
  path: '/',
  domain: 'localhost',
  secure: false,
  // secureProxy: ,
  httpOnly: true,
  signed: true,
  overwrite: true,
});