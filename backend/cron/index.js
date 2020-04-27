const CronJob = require('cron').CronJob;
const { testCron, refreshAllMaterializedViews, dumpDatabase, diffUploads } = require('./onTickFunctions');

const onTickFunction0 = () => {};
const onTickFunction1 = testCron;
const onTickFunction2 = refreshAllMaterializedViews;
const onTickFunction3 = dumpDatabase;
const onTickFunction4 = diffUploads;

const everySecond = '* * * * * *';
const everyMinute = '0 * * * * *';
const everyHour = '0 0 * * * *';
const everyDay = '0 0 0 * * *';

module.exports = new CronJob({
  cronTime: everySecond,
  onTick: onTickFunction1,
  onComplete: () => {},
  start: true,
  timezone: 'America/Sao_Paulo',
});
