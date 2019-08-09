// Initialization and imports
const express = require('express');
const app = express();
const port = 3001;
const middleware = require('./middleware')
const { postgraphile } = require("postgraphile");

// Middlewares
// app.use(middleware);
app.use(postgraphile(
  process.env.DATABASE_URL || "postgres://postgres:123456@localhost:5432/cmms",
  "public",
  {
    // Check other options at:
    // https://www.graphile.org/postgraphile/usage-library/#api-postgraphilepgconfig-schemaname-options
    watchPg: true,
    enableCors: true,
    exportJsonSchemaPath: "../schema.json",
    exportGqlSchemaPath: "../schema.graphql",
    sortExport: true,
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