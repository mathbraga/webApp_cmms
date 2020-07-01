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
const { expressStatic, loginStatic } = require('./middlewares/express-static');
// Cookie related
const cookieSession = require('./middlewares/cookie-session');
const cookieParser = require('cookie-parser');

const passport = require('./middlewares/passport');
const morgan = require('./middlewares/morgan');
const checkAuthUser = require('./middlewares/check-auth-user');
const postgraphile = require('./middlewares/postgraphile');
// const path = require('path');

// App configuration
app.set('x-powered-by', false);
// app.use(express.static(path.join(process.cwd(), "../frontend/build")));

// Middlewares
app.use(cors);
app.use(expressJson);
app.use(expressStatic);
app.use(loginStatic);
app.use(cookieSession);
app.use(cookieParser());
app.use(passport.initialize());
app.use(passport.session());
app.use(morgan);
app.use(checkAuthUser);

// Routes
app.use(paths.auth, authRoute);
app.use(paths.db, uploadRoute);
app.use(paths.files, downloadRoute);
app.use(paths.redmine, redmineRoute);
app.use(paths.email, emailRoute);

// PostGraphile route
app.use(postgraphile);

// 404 Error
app.use((req, res) => res.status(404).send("Página não encontrada."));

module.exports = app;
