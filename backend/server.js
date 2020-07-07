// Load environment variables
const path = require('path');
const envFilename = process.env.NODE_ENV === 'production' ? '.env.pro' : '.env.dev';
require('dotenv').config({
  path: path.resolve(process.cwd(), envFilename),
});
// console.log(process.env);

const app = require('./app');
const http = require('http');
const server = http.createServer(app);
const port = process.env.HTTP_PORT;

// Cron jobs
const cronJobs = require('./cron');

// Listen for connections on specified port
server.listen(port, () => console.log(`Server listening on port ${port}!`));
