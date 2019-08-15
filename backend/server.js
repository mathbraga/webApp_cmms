// Initialization and imports
const express = require('express');
const app = express();
const port = 3001;
const { postgraphile } = require("postgraphile");
const http = require('http');
const server = http.createServer(app);
// const middleware = require('./middleware');
// const cors = require('cors')
// const cookieParser = require('cookie-parser');

// Middlewares
// app.use(cors());
// app.use(express.json());
// app.use(cookieParser());
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
    graphqlRoute: "/db",
    graphiql: true,
    graphiqlRoute: "/graphiql",
    enhanceGraphiql: true,
    disableQueryLog: false,
    dynamicJson: true,
    showErrorStack: 'json',
    extendedErrors: ['hint', 'detail', 'errcode'],
    pgSettings: async req => {
      
      var role = 'unauth';
      
      console.log(JSON.stringify(req.body))
      
      return {
      'role': role,
      }
    }
  }
));

// Listen for connections on specified port
server.listen(port, () => console.log(`Server listening on port ${port}!`));