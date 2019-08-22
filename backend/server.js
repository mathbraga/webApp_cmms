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
const LocalStrategy = require('passport-local').Strategy;
const cookieSession = require('cookie-session');
const registerRoute = require('./routes/register');
const loginRoute = require('./routes/login');
const logoutRoute = require('./routes/logout');

// app.set('trust proxy', true);

// Middlewares
// app.use(cors());
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

// passport.deserializeUser(async (userId, done) => {
//   console.log('inside deserialization')
//   try {
//     let data = await client.query('SELECT id FROM users WHERE id = $1', [userId]);
//     if (data.rows.length === 0){
//       return done(new Error('user not found'));
//     }
//     done(null, user);
//   } catch (e) {
//     done(e);
//   }
// });
app.use(function(req, res, next){
  console.log('LOGGING MIDDLEWARE FOR ALL ROUTES');
  console.log('req user: ' + JSON.stringify(req.user));
  console.log(req.session.isNew);
  console.log('req session: ' + JSON.stringify(req.session));
  next();
})



app.use("/register", registerRoute);
app.use("/login", loginRoute);
app.use("/logout", logoutRoute);
app.use(function(req, res, next){
  // console.log(req.user)
  next()
})

app.get('/teste', function(req, res){
  console.log('inside /teste')
  console.log(req.session)
  console.log(req.cookies)
  console.log(req.signedCookies)
  console.log(req.session.isNew)

  res.json({'response': '/teste'})
})

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