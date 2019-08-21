// Load environment variables
require('dotenv').config();

// Initialization and imports
const express = require('express');
const app = express();
const port = 3001;
const { postgraphile } = require("postgraphile");
const http = require('http');
const server = http.createServer(app);
const middleware = require('./middleware');
const cors = require('cors')
const cookieParser = require('cookie-parser');

const registerRoute = require('./routes/register');
// const loginRoute = require('./routes/login');
// const logoutRoute = require('./routes/logout');
// app.use("/login", loginRoute);
// app.use("/logout", logoutRoute);


// console.log(process.env)

// Middlewares
app.use(cors());
app.use(express.json());
// app.use(cookieParser());
app.use(middleware);
app.use("/register", registerRoute);

// app.use('/db', function(req, res, next){
//   if(req.headers.authorization === undefined){
//     res.json({E: 'NÃO ESTÁ LOGADO'})
//   } else {
//     console.log('primeiro middleware')
//     next()
//   }
// });

app.use(postgraphile(
  
  // pgConfig (object)
  {
    host:     process.env.DB_HOST,
    port:     process.env.DB_PORT,
    database: process.env.DB_DBNAME,
    user:     process.env.DB_ADMIN,
    password: process.env.DB_PASS,
  },

  // schemaName (array of strings)
  ["public"/*, "private_schema"*/],

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
    // pgSettings: async (req, res) => {
      
    //   console.dir(res)
      
    //   var role = 'unauth';      
    //   return {
    //   'role': role,
    //   }
    // }
  }
));

// app.post('/db', function(req, res, next){
//   console.log('segundo middleware');
// })

// Listen for connections on specified port
server.listen(port, () => console.log(`Server listening on port ${port}!`));