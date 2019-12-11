const { postgraphile } = require('postgraphile');
const paths = require('../../paths');
const { pgConfig } = require('../../db');

module.exports = postgraphile(
  pgConfig,
  ['public'],
  { 
    watchPg: true,
    enableCors: false,
    graphqlRoute: paths.db,
    graphiql: true,
    graphiqlRoute: paths.graphiql,
    // ignoreIndexes: false,
    // subscriptions: true,
    enhanceGraphiql: true,
    disableDefaultMutations: true,
    disableQueryLog: false,
    dynamicJson: true,
    showErrorStack: 'json',
    extendedErrors: ['hint', 'detail', 'errcode'],
    exportJsonSchemaPath: '../frontend/src/schema.json',
    exportGqlSchemaPath: '../frontend/src/schema.graphql',
    sortExport: true,
    pgSettings: async req => {
      const [person_id, role] = req.session.passport ? req.session.passport.user.split('-') : ['1', 'visitor'];
      return {
        'role': role,
        'auth.data.person_id': person_id,
      }
    }
  }
);
