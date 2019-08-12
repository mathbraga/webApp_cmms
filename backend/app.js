// Initialization and imports
const express = require('express');
const app = express();
const port = 3001;
const middleware = require('./middleware')
const { postgraphile } = require("postgraphile");

// Middlewares
// app.use(middleware);
app.use(postgraphile(
  
  // pgConfig (object)
  {
    host: '172.30.49.152',
    port: 5432,
    database: 'cmms',
    user: 'postgres',
    password: '123456',
  },

  // schemaName (string)
  "public",

  // options (object)
  {
    // Check other options at:
    // https://www.graphile.org/postgraphile/usage-library/#api-postgraphilepgconfig-schemaname-options
    watchPg: true,
    enableCors: true,
    // exportJsonSchemaPath: "../schema.json",
    // exportGqlSchemaPath: "../schema.graphql",
    // sortExport: true,
    graphqlRoute: "/",
    graphiql: true,
    graphiqlRoute: "/graphiql",
    enhanceGraphiql: true,
    disableQueryLog: false,
    dynamicJson: true,
    showErrorStack: 'json',
    extendedErrors: ['hint', 'detail', 'errcode'],
  }
));

// Listen for connections on specified port
app.listen(port, () => console.log(`App listening on port ${port}!`));