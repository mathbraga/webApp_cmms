const morgan = require('morgan');

morgan.token('separator', () => ('-----------------------------------------------------------------------------------------------------'));

morgan.token('user', req => (
  'User: ' + JSON.stringify(req.user) +
  '    New session? ' + req.session.isNew +
  '    Session: ' + JSON.stringify(req.session)
));

module.exports = morgan(`
:separator
:date[iso]    :remote-addr    :method    :url    :status    :response-time
:user
`);