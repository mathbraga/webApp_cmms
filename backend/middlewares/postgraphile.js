const { postgraphile } = require('postgraphile');
const paths = require('../paths');
const { pgPool } = require('../db');

module.exports = postgraphile(
  pgPool,
  ['api'],
  { 
    watchPg: process.env.NODE_ENV === 'development',
    retryOnInitFail: false,
    enableCors: false,
    graphqlRoute: paths.db,
    graphiql: process.env.NODE_ENV === 'development',
    graphiqlRoute: paths.graphiql,
    // ignoreIndexes: false,
    // subscriptions: true,
    enhanceGraphiql: process.env.NODE_ENV === 'development',
    disableDefaultMutations: true,
    disableQueryLog: process.env.NODE_ENV !== 'development',
    dynamicJson: true,
    showErrorStack: 'json',
    extendedErrors: ['hint', 'detail', 'errcode'],
    // exportJsonSchemaPath: process.env.NODE_ENV === 'development' ? '../frontend/src/schema.json' : false,
    // exportGqlSchemaPath: process.env.NODE_ENV === 'development' ? '../frontend/src/schema.graphql' : false,
    // sortExport: true,
    pgSettings: async req => {
      const [person_id, role] = req.session.populated ? req.session.passport.user.split('-') : ['0', 'visitor'];
      const readOnly = /query/i.test(req.body.query) ? 'on' : 'off';
      return {
        // 'transaction_read_only': readOnly,
        'role': role,
        'statement_timeout': 5000,
        'cookie.session.person_id': person_id,
      }
    }
  }
);
