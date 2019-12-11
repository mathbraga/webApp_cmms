const morgan = require('morgan');

morgan.token('separator', () => ('-----------------------------------------------------------------------------------------------------'));

morgan.token('user', req => (
  'User: ' + JSON.stringify(req.user) +
  '    Session: ' + JSON.stringify(req.session)
));

morgan.token('body', req => (JSON.stringify(req.body)));

module.exports = morgan(`
:separator
:date[iso]    :remote-addr    :method    :url    :status    :response-time
:user`);