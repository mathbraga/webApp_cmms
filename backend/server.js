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
const passport = require('passport');
const cookieSession = require('cookie-session');
const registerRoute = require('./routes/register');
const loginRoute = require('./routes/login');
const logoutRoute = require('./routes/logout');

// Configure application (https://expressjs.com/en/4x/api.html#app.set)
// app.set('trust proxy', 1);

// Middlewares
app.use(cors({
  origin: true,
  credentials: true,
}));
app.use(cookieSession({
  name: 'cmms:session',
  keys: ['key0', 'key1', 'key2'],
  signed: true,
  httpOnly: true
}));
app.use(passport.initialize());
app.use(passport.session());
app.use(middleware);
app.use("/register", registerRoute);
app.use("/login", loginRoute);
app.use("/logout", logoutRoute);

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
  ["public"],

  // options (object)
  {
    // Check other options at:
    // https://www.graphile.org/postgraphile/usage-library/#api-postgraphilepgconfig-schemaname-options
    watchPg: true,
    enableCors: false,
    graphqlRoute: "/db",
    graphiql: true,
    graphiqlRoute: "/graphiql",
    enhanceGraphiql: true,
    disableQueryLog: false,
    dynamicJson: true,
    showErrorStack: 'json',
    extendedErrors: ['hint', 'detail', 'errcode'],
    pgSettings: async req => {
      const role = req.user ? 'auth': 'unauth';
      const person_id = req.user ? req.user : 'anonymous';
      return {
      'role': role,
      'auth.data.person_id': person_id,
      }
    }
  }
));

// Listen for connections on specified port
server.listen(port, () => console.log(`Server listening on port ${port}!`));