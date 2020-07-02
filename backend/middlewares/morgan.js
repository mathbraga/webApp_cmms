const morgan = require('morgan');
const fs = require('fs');
const path = require('path');
const paths = require('../paths');

morgan.token('separator', req => '-----------------------------------------------------------------------------------------------------');
morgan.token('user', req => JSON.stringify(req.user));
morgan.token('session', req => JSON.stringify(req.session));
morgan.token('body', req => req.path === paths.login ? '{ SECRET }' : JSON.stringify(req.body));

const logFormatDevelopment = `\n:separator\n:date[iso]    :remote-addr    :method    :url    :status    :response-time ms\nUser: :user    Session: :session\nBody: :body`;
const logFormatProduction = `:date[iso]    :remote-addr    :method    :url    :status    :response-time    :user    :session    :body`;
const logFormat = process.env.NODE_ENV === 'development' ? logFormatDevelopment : logFormatProduction;

const logStreamDevelopment = process.stdout;
const logStreamProduction = fs.createWriteStream(path.join(process.cwd(), paths.reqsLog), { flags: 'a' });
const logStream = process.env.NODE_ENV === 'development' ? logStreamDevelopment : logStreamProduction;

module.exports = morgan(
  logFormat,
  {
    skip: () => (process.env.NODE_ENV === 'test'),
    stream: logStream,
  }
);
