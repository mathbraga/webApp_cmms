// Load environment variables
require('dotenv').config();

// Initialization and imports
// const compression = require('compression'); // Add this in production?
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
const authRoute = require('./routes/auth');
const uploadRoute = require('./routes/upload');
const filesRoute = require('./routes/files');
// const cronJob = require('./cron');

// Configure application (https://expressjs.com/en/4x/api.html#app.set)
// app.set('trust proxy', 1);

// Middlewares
// app.use(compression());
app.use(cors({
  origin: true,
  credentials: true,
}));
app.use(express.json());
app.use(express.static('public'));
app.use(cookieSession({
  name: 'cmms:session',
  keys: ['key0', 'key1', 'key2'],
  signed: true,
  httpOnly: true
}));
app.use(passport.initialize());
app.use(passport.session());
app.use(middleware);

// Routes
app.use("/auth", authRoute);
app.use("/db", uploadRoute);
app.use("/files", filesRoute);

// PostGraphile route
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
      const [person_id, role] = req.session.passport ? req.session.passport.user.split('-') : ['0', 'unauth'];
      return {
        'role': role,
        'auth.data.person_id': person_id,
      }
    }
  }
));

// Listen for connections on specified port
server.listen(port, () => console.log(`Server listening on port ${port}!`));