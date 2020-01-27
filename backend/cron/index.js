const CronJob = require('cron').CronJob;
const { testCron, refreshAllMaterializedViews, dumpDatabase, diffUploads } = require('./onTickFunctions');

const onTickFunction0 = () => {};
const onTickFunction1 = testCron;
const onTickFunction2 = refreshAllMaterializedViews;
const onTickFunction3 = dumpDatabase;
const onTickFunction4 = diffUploads;

module.exports = new CronJob({
  cronTime: '* * * * * *',
  onTick: onTickFunction0,
  onComplete: null,
  start: true,
  timezone: 'America/Sao_Paulo',
});
