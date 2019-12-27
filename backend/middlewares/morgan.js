const morgan = require('morgan');
const fs = require('fs');
const path = require('path');

morgan.token('separator', () => ('-----------------------------------------------------------------------------------------------------'));

morgan.token('user', req => (
  'User: ' + JSON.stringify(req.user) +
  '    Session: ' + JSON.stringify(req.session)
));

morgan.token('body', req => (JSON.stringify(req.body)));

const logStream = fs.createWriteStream(path.join(process.cwd(), 'logs/reqs'), { flags: 'a' });

module.exports = morgan(`
:separator
:date[iso]    :remote-addr    :method    :url    :status    :response-time ms
:user`, {
  skip: () => (process.env.NODE_ENV === 'test'),
  stream: process.env.NODE_ENV === 'development' ? process.stdout : logStream,
});