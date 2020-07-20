// Initialization and imports
const express = require('express');
const app = express();
const loginRoute = require('./routes/login');
const logoutRoute = require('./routes/logout');
const uploadRoute = require('./routes/upload');
const downloadRoute = require('./routes/download');
const redmineRoute = require('./routes/redmine');
const paths = require('./paths');
const cors = require('./middlewares/cors');
const expressJson = require('./middlewares/express-json');
const expressStatic = require('./middlewares/express-static');
const cookieSession = require('./middlewares/cookie-session');
const passport = require('./middlewares/passport');
const morgan = require('./middlewares/morgan');
const checkAuthUser = require('./middlewares/check-auth-user');
const postgraphile = require('./middlewares/postgraphile');

// App configuration
app.set('x-powered-by', false);

// Middlewares
app.use(cors);
app.use(expressJson);
app.use(cookieSession);
app.use(passport.initialize());
app.use(passport.session());
app.use(morgan.logConsole);
app.use(morgan.logFile);
app.use(checkAuthUser);
app.use(expressStatic);

// Routes
app.use(paths.login, loginRoute);
app.use(paths.logout, logoutRoute);
app.use(paths.upload, uploadRoute);
app.use(paths.download, downloadRoute);
app.use(paths.redmine, redmineRoute);

// PostGraphile route
app.use(postgraphile);

// 404 Error
app.use((req, res) => res.status(404).send("Página não encontrada."));

module.exports = app;
