const { pgClient } = require('../configs');
const CronJob = require('cron').CronJob;
const util = require('util');
const exec = util.promisify(require('child_process').exec);
const { cronConfig } = require('../configs');

module.exports = new CronJob(
  cronConfig.cronTime,
  cronConfig.onTick,
  cronConfig.onComplete,
  cronConfig.start,
  cronConfig.timezone
);