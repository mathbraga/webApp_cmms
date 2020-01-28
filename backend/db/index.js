const { Pool } = require('pg');

const pgConfig = {
  user: process.env.PGUSER || 'postgres',
  host: process.env.PGHOST || 'localhost',
  database: process.env.PGDATABASE || 'new_cmms',
  password: process.env.PGPASSWORD || '123456',
  port: process.env.PGPORT || 5432,
};

const pgPool = new Pool(pgConfig);

module.exports = {
  pgConfig: pgConfig,
  pgPool: pgPool,
  query: (queryText, params, callback) => {
    return pgPool.query(queryText, params, callback);
  },
}