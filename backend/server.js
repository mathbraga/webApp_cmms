// Load environment variables
require('dotenv').config();

// Initialization and imports
const express = require('express');
const app = express();
const port = process.env.EXPRESS_PORT;
const http = require('http');
const server = http.createServer(app);
const authRoute = require('./routes/auth');
const uploadRoute = require('./routes/upload');
const downloadRoute = require('./routes/download');
const redmineRoute = require('./routes/redmine');
const emailRoute = require('./routes/email');
const paths = require('./paths');
const cors = require('./middlewares/cors');
const json = require('./middlewares/json');
const static = require('./middlewares/static');
const cookieSession = require('./middlewares/cookie-session');
const passport = require('./middlewares/passport');
const logger = require('./middlewares/logger');
const postgraphile = require('./middlewares/postgraphile');
// const cron = require('./middlewares/cron');

// Middlewares
app.use(cors);
app.use(json);
app.use(static);
app.use(cookieSession);
app.use(passport.initialize());
app.use(passport.session());
app.use(logger);

// Routes
app.use(paths.auth, authRoute);
app.use(paths.db, uploadRoute);
app.use(paths.download, downloadRoute);
app.use(paths.redmine, redmineRoute);
app.use(paths.email, emailRoute);

// PostGraphile route
app.use(postgraphile);

// Listen for connections on specified port
server.listen(port, () => console.log(`Server listening on port ${port}!`));