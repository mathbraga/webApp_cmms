const initOptions = {
  capSQL: true,
  pgNative: false
};

const pgp = require('pg-promise')(initOptions);

// http://vitaly-t.github.io/pg-promise/Database.html

// Using a configuration object:
const configObj = {
  host: '172.30.49.152',
  port: 5432,
  database: 'cmms',
  user: 'postgres',
  password: '123456'
};
const db = pgp(configObj);

module.exports = db;