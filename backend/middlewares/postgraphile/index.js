const config = require('./config');
const pgConfig = require('../pg/config');
const { postgraphile } = require('postgraphile');

module.exports = postgraphile(pgConfig, config.schemas, config.options);
