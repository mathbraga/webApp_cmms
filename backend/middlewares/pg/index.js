const { Client } = require('pg');
const config = require('./config');

const pgClient = new Client(config);
pgClient.connect();

module.exports = pgClient;