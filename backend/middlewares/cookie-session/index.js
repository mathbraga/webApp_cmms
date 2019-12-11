const cookieSession = require('cookie-session');

module.exports = cookieSession({
  name: 'cmms:session',
  keys: ['key0', 'key1', 'key2'],
  signed: true,
  httpOnly: true,
});