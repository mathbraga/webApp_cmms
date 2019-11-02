const paths = require('./paths');
const { Client } = require('pg');

const corsConfig = {
  origin: true,
  credentials: true,
};

const staticConfig = {
  root: 'public',
  options: {}
};

const cookieSessionConfig = {
  name: 'cmms:session',
  keys: ['key0', 'key1', 'key2'],
  signed: true,
  httpOnly: true,
};

const pgConfig = {
  user: process.env.DB_ADMIN || 'postgres',
  host: process.env.DB_HOST || 'localhost',
  database: process.env.DB_DBNAME || 'dbname',
  password: process.env.DB_PASS || '123456',
  port: process.env.DB_PORT || 5432
};

const pgClient = new Client(pgConfig);
pgClient.connect();

const postgraphileConfig = {
  schemas: ['public'],
  options: { 
    watchPg: true,
    enableCors: false,
    graphqlRoute: paths.db,
    graphiql: true,
    graphiqlRoute: paths.graphiql,
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
  }
};

module.exports = {
  corsConfig,
  staticConfig,
  cookieSessionConfig,
  pgConfig,
  pgClient,
  postgraphileConfig
};
