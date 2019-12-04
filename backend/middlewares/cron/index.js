const cron = require('cron').CronJob;
const config = require('./config');

module.exports = cron(config);