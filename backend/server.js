// Load environment variables
require('dotenv').config();

// Initialization and imports
// const compression = require('compression'); // Add this in production?
const express = require('express');
const app = express();
const port = process.env.EXPRESS_PORT;
const { postgraphile } = require("postgraphile");
const http = require('http');
const server = http.createServer(app);
const middleware = require('./middleware');
const cors = require('cors')
const passport = require('passport');
const cookieSession = require('cookie-session');
const authRoute = require('./routes/auth');
const uploadRoute = require('./routes/upload');
const gqlUploadRoute = require('./routes/gqlupload');
const downloadRoute = require('./routes/download');
const redmineRoute = require('./routes/redmine');
const emailRoute = require('./routes/email');
const { corsConfig, staticConfig, cookieSessionConfig, pgConfig, postgraphileConfig } = require('./configs');
const paths = require('./paths');
// const cronJob = require('./cron');

// Configure application (https://expressjs.com/en/4x/api.html#app.set)
// app.set('trust proxy', 1);

// Middlewares
// app.use(compression());
app.use(cors(corsConfig));
app.use(express.json());
app.use(express.static(staticConfig.root));
app.use(cookieSession(cookieSessionConfig));
app.use(passport.initialize());
app.use(passport.session());
app.use(middleware);

// Routes
app.use(paths.auth, authRoute);
// app.use(paths.db, uploadRoute);
app.use(paths.db, gqlUploadRoute);
app.use(paths.download, downloadRoute);
app.use(paths.redmine, redmineRoute);
app.use(paths.email, emailRoute);

// PostGraphile route
app.use(postgraphile(pgConfig, postgraphileConfig.schemas, postgraphileConfig.options));

// Listen for connections on specified port
server.listen(port, () => console.log(`Server listening on port ${port}!`));