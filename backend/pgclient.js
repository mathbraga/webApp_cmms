const { Client } = require('pg');

const client = new Client({
  user: process.env.DB_ADMIN,
  host: process.env.DB_HOST,
  database: process.env.DB_DBNAME,
  password: process.env.DB_PASS,
  port: process.env.DB_PORT,
})

client.connect();

module.exports = client;
