const CronJob = require('cron').CronJob;
const { cronConfig } = require('../configs');

module.exports = new CronJob(
  cronConfig.cronTime,
  cronConfig.onTick,
  cronConfig.onComplete,
  cronConfig.start,
  cronConfig.timezone
);