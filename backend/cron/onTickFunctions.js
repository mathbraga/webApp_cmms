const util = require('util');
const exec = util.promisify(require('child_process').exec);
const fs = require("fs");
const path = require('path');
const db = require('../db');
const paths = require('../paths');

const testCron = () => {
  console.log('... Testing Cron ...');
}

const refreshAllMaterializedViews = async () => {
  try {
    const { rows: [ { timestamp } ] } = await db.query('select web.refresh_all_materialized_views() as timestamp');
    console.log('All materialized views refreshed at: ' + timestamp);
  }
  catch (error) {
    console.log(error);
  }
}

const dumpDatabase = async () => {
  try {
    const output = await exec(`pg_dump -f dumps/dump.sql -d ${process.env.PGDATABASE}`);
    console.log(`pg_dump executed successfully at: ${new Date()}`);
  } catch(error){
    console.log(error);
  }
}

const diffUploads = async () => {

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

  } catch(error){
    console.log(error);
  }
}

const onTickSecond = () => {
  if (process.env.CRON_TEST !== undefined) testCron();
}

const onTickMinute = () => {
  if (process.env.CRON_DUMP !== undefined) dumpDatabase();
  if (process.env.CRON_REFRESH !== undefined) refreshAllMaterializedViews();
  if (process.env.CRON_DIFF !== undefined) diffUploads();
}

module.exports = {
  onTickSecond,
  onTickMinute,
};
