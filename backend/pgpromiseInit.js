const initOptions = {
  capSQL: true,
  pgNative: false
};

const pgp = require('pg-promise')(initOptions);

const configObj = {
  host: 'localhost',
  port: 5432,
  database: 'cmms',
  user: 'postgres',
  password: '123456'
};

const db = pgp(configObj);

module.exports = db;