// Load environment variables
require('dotenv').config();

const app = require('./app');
const http = require('http');
const server = http.createServer(app);
const port = process.env.EXPRESS_PORT;

// Listen for connections on specified port
server.listen(port, () => console.log(`Server listening on port ${port}!`));
