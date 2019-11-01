const { Client } = require('pg');

const corsConfig = {
  origin: true,
  credentials: true,
};

const cookieSessionConfig = {
  name: 'cmms:session',
  keys: ['key0', 'key1', 'key2'],
  signed: true,
  httpOnly: true,
};

const pgConfig = {
  user: process.env.DB_ADMIN,
  host: process.env.DB_HOST,
  database: process.env.DB_DBNAME,
  password: process.env.DB_PASS,
  port: process.env.DB_PORT,
};

const pgClient = new Client(pgConfig);
pgClient.connect();

const postgraphileConfig = {
  watchPg: true,
  enableCors: false,
  graphqlRoute: "/db",
  graphiql: true,
  graphiqlRoute: "/graphiql",
  enhanceGraphiql: true,
  disableQueryLog: false,
  dynamicJson: true,
  showErrorStack: 'json',
  extendedErrors: ['hint', 'detail', 'errcode'],
  pgSettings: async req => {
    const [person_id, role] = req.session.passport ? req.session.passport.user.split('-') : ['0', 'visitor'];
    return {
      'role': role,
      'auth.data.person_id': person_id,
    }
  }
};

module.exports = {
  corsConfig,
  cookieSessionConfig,
  pgConfig,
  pgClient,
  postgraphileConfig
};
