const cookieSession = require('cookie-session');
const config = require('./config');

module.exports = cookieSession(config);