// Load environment variables
require('dotenv').config();

// Initialization and imports
const express = require('express');
const app = express();
const port = 3001;
const { postgraphile } = require("postgraphile");
const http = require('http');
const server = http.createServer(app);
// const middleware = require('./middleware');
const cors = require('cors')
const cookieParser = require('cookie-parser');

// console.log(process.env)

// Middlewares
app.use(cors());
app.use(express.json());
app.use(cookieParser());
// app.use(middleware);
// app.use('/db', function(req, res, next){
//   console.log(JSON.stringify(req.get('Cookie')));
//   next()
// });

app.use(postgraphile(
  
  // pgConfig (object)
  {
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    database: process.env.DB_DBNAME,
    user: process.env.DB_ADMIN,
    password: process.env.DB_PASS,
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
    jwtPgTypeIdentifier: 'public.jwt_token',
    jwtSecret: 'SECRET',
    pgDefaultRole: 'unauth',
    // pgSettings: async req => {
      
    //   // console.dir(req.jwtperson_id)
      
    //   var role = 'unauth';      
    //   return {
    //   'role': role,
    //   }
    // }
  }
));

// Listen for connections on specified port
server.listen(port, () => console.log(`Server listening on port ${port}!`));