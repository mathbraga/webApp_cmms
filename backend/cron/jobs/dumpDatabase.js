const CronJob = require('cron').CronJob;
const util = require('util');
const exec = util.promisify(require('child_process').exec);
const fs = require('fs');
const path = require('path');
const paths = require('../../paths');

const dumpDatabase = async () => {
  try {
    const output = await exec(`pg_dump -f dumps/dump.sql -d ${process.env.PGDATABASE}`);
    const logContent = `pg_dump executed successfully at: ${new Date()}`;
    fs.writeFile(path.join(process.cwd(), paths.dbDumpLog), logContent, error => {
      if(error){
        console.log(error);
      }
    });
  } catch(dumpError){
    fs.writeFile(path.join(process.cwd(), paths.dbDumpLog), dumpError, error => {
      if(error){
        console.log(error);
      }
    });
  }
}

module.exports = process.env.CRON_DUMP !== '' ? new CronJob({
  cronTime: process.env.CRON_DUMP,
  onTick: dumpDatabase,
  onComplete: () => {},
  start: true,
  timezone: 'America/Sao_Paulo',
}) : null;
