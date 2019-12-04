module.exports = {
  user: process.env.DB_ADMIN || 'postgres',
  host: process.env.DB_HOST || 'localhost',
  database: process.env.DB_DBNAME || 'dbname',
  password: process.env.DB_PASS || '123456',
  port: process.env.DB_PORT || 5432,
};