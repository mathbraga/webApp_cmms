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
const passport = require('passport');
// const LocalStrategy = require('passport-local').Strategy;
const cookieSession = require('cookie-session');
const registerRoute = require('./routes/register');
const loginRoute = require('./routes/login');
const logoutRoute = require('./routes/logout');

// app.set('trust proxy', true);

// Middlewares
app.use(cors({
  origin: true,
  credentials: true,
  // allowedHeaders: ['Origin', 'X-Requested-With', 'Content-Type', 'Content-Length', 'Accept', 'Authorization', 'X-Apollo-Tracing'],
}));
app.use(middleware);
app.use(express.json());
app.use(express.urlencoded({extended: false}));
app.use(cookieParser());
app.use(cookieSession({
  name: 'cmms:session',
  keys: ['key0', 'key1', 'key2'],
  secret: 'secret',
  signed: true,
  httpOnly: false
}));
app.use(passport.initialize());
app.use(passport.session());
app.use("/register", registerRoute);
app.use("/login", loginRoute);
app.use("/logout", logoutRoute);

// Testing route (/teste)
app.get('/teste', function(req, res){
  console.log('inside /teste')
  console.log(req.session)
  console.log(req.cookies)
  console.log(req.signedCookies)
  console.log(req.session.isNew)
  res.json({'response': '/teste'})
})

// PostGraphile route (/db)
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
    enableCors: false,
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
    // jwtPgTypeIdentifier: 'public.jwt_token',
    // jwtSecret: 'SECRET',
    // pgDefaultRole: 'unauth',
    pgSettings: async req => {
      const role = req.user ? 'auth': 'unauth';
      return {
      'role': role,
      // 'jwt.claims.user_id': `${req.user.id}`,
      }
    }
  }
));

// Listen for connections on specified port
server.listen(port, () => console.log(`Server listening on port ${port}!`));