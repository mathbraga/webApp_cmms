const { Pool } = require('pg');

const pgConfig = {
  user: process.env.PGUSER || 'postgres',
  host: process.env.PGHOST || 'localhost',
  database: process.env.PGDATABASE || 'cmms9',
  password: process.env.PGPASSWORD || '123456',
  port: process.env.PGPORT || 5432,
};

const pool = new Pool(pgConfig);

module.exports = {
  pgConfig: pgConfig,
  query: (queryText, params, callback) => {
    return pool.query(queryText, params, callback);
  },
}