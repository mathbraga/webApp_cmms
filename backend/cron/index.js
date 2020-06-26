const CronJob = require('cron').CronJob;
const { onTickSecond, onTickMinute } = require('./onTickFunctions');

const everySecond = '* * * * * *';
const everyMinute = '0 * * * * *';
const everyHour = '0 0 * * * *';
const everyDay = '0 0 0 * * *';

module.exports = {
  everySecond: new CronJob({
    cronTime: everySecond,
    onTick: onTickSecond,
    onComplete: () => {},
    start: true,
    timezone: 'America/Sao_Paulo',
  }),
  everyMinute: new CronJob({
    cronTime: everyMinute,
    onTick: onTickMinute,
    onComplete: () => {},
    start: true,
    timezone: 'America/Sao_Paulo',
  }),
};
