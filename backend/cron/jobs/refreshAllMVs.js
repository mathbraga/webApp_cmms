const CronJob = require('cron').CronJob;
const fs = require("fs");
const path = require('path');
const db = require('../../db');
const paths = require('../../paths');

const refreshAllMVs = async () => {
  try {
    const { rows: [ { timestamp } ] } = await db.query('select web.refresh_all_materialized_views() as timestamp');
    const logContent = `All materialized views refreshed at: ${timestamp}`;
    fs.writeFile(path.join(process.cwd(), paths.refreshMVLog), logContent, error => {
      if(error){
        console.log(error);
      }
    });
  }
  catch (refreshError) {
    fs.writeFile(path.join(process.cwd(), paths.refreshMVLog), refreshError, error => {
      if(error){
        console.log(error);
      }
    });
  }
}

module.exports = process.env.CRON_REFRESH !== '' ? new CronJob({
  cronTime: process.env.CRON_REFRESH,
  onTick: refreshAllMVs,
  onComplete: () => {},
  start: true,
  timezone: 'America/Sao_Paulo',
}) : null;
