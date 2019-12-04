const { postgraphile } = require('postgraphile');

module.exports = postgraphile(
  {
    user: process.env.DB_ADMIN || 'postgres',
    host: process.env.DB_HOST || 'localhost',
    database: process.env.DB_DBNAME || 'dbname',
    password: process.env.DB_PASS || '123456',
    port: process.env.DB_PORT || 5432,
  },
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
