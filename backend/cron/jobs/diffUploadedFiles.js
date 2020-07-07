const CronJob = require('cron').CronJob;
const fs = require('fs');
const path = require('path');
const db = require('../../db');
const paths = require('../../paths');

const diffUploadedFiles = async () => {

  try {
    const { rows: [ { dbUUIDs } ] } = await db.query('select web.get_all_files_uuids() as "dbUUIDs"');

    const UUIDs = fs.readdirSync(path.join(process.cwd(), paths.files));

    const diffUUIDs = UUIDs.filter(uuid => (!dbUUIDs.includes(uuid)));

    const diffFileContent =
      'List of uploaded files not registered in the database\n' +
      '(diff script executed at ' + (new Date()).toString() + ')\n' +
      '-----------------------------------------------------------------------\n' +
      diffUUIDs.join('\n').replace(/\.gitkeep\n/, '') +
      '\n'
    ;

    fs.writeFile(path.join(process.cwd(), paths.filesDiffLog), diffFileContent, error => {
      if(error){
        console.log(error);
      }
    });

  } catch(diffError){
    fs.writeFile(path.join(process.cwd(), paths.filesDiffLog), diffError, error => {
      if(error){
        console.log(error);
      }
    });
  }
}

module.exports = process.env.CRON_DIFF !== '' ? new CronJob({
  cronTime: process.env.CRON_DIFF,
  onTick: diffUploadedFiles,
  onComplete: () => {},
  start: true,
  timezone: 'America/Sao_Paulo',
}) : null;
