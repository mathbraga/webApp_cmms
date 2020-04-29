// Initialization and imports
const express = require('express');
const app = express();
const authRoute = require('./routes/auth');
const uploadRoute = require('./routes/upload');
const downloadRoute = require('./routes/download');
const redmineRoute = require('./routes/redmine');
const emailRoute = require('./routes/email');
const paths = require('./paths');
const cors = require('./middlewares/cors');
const expressJson = require('./middlewares/express-json');
const expressStatic = require('./middlewares/express-static');
const cookieSession = require('./middlewares/cookie-session');
const passport = require('./middlewares/passport');
const morgan = require('./middlewares/morgan');
const redirectUnauth = require('./middlewares/redirect-unauth');
const postgraphile = require('./middlewares/postgraphile');

// App configuration
app.set('x-powered-by', false);

// Middlewares
app.use(cors);
app.use(expressJson);
app.use(expressStatic);
app.use(cookieSession);
app.use(passport.initialize());
app.use(passport.session());
app.use(morgan);
app.use(redirectUnauth);

// Routes
app.use(paths.auth, authRoute);
app.use(paths.db, uploadRoute);
app.use(paths.files, downloadRoute);
app.use(paths.redmine, redmineRoute);
app.use(paths.email, emailRoute);

// PostGraphile route
app.use(postgraphile);

module.exports = app;
