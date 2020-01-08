const util = require('util');
const exec = util.promisify(require('child_process').exec);
const fs = require("fs");
const path = require('path');
const db = require('../db');
const paths = require('../paths');

const testCron = () => {
  console.log('... Testing Cron ...');
};

const refreshAllMaterializedViews = async () => {
  try {
    const { rows: [ { timestamp } ] } = await db.query('select refresh_all_materialized_views() as timestamp');
    console.log('All materialized views refreshed at: ' + timestamp);
  }
  catch (error) {
    console.log(error);
  }
};

const dumpDatabase = async () => {
  try {
    const output = await exec('pg_dump -f dumps/dump.sql -d ' + process.env.PGDATABASE);
    console.log('pg_dump executed successfully at: ' + new Date);
  } catch(error){
    console.log(error);
  }
};

const diffUploads = async () => {

  try {
    const { rows: [ { dbUUIDs } ]} = await db.query('select get_all_files_uuids() as "dbUUIDs"');
    // console.log(dbUUIDs);
    
    const UUIDs = fs.readdirSync(path.join(process.cwd(), paths.files));
    // console.log(UUIDs);

    const diffFile = fs.createWriteStream(path.join(process.cwd(), paths.filesDiffLog), { flags: 'w' });

    const diffUUIDs = UUIDs.filter(uuid => (!dbUUIDs.includes(uuid)));
    // console.log(diffUUIDs);

    const diffFileContent = (
      'List of uploaded files not registered in the database\n' +
      '(diff script executed at ' + new Date + ')\n' +
      '-------------------------------------------------------------------------\n' +
      diffUUIDs.join('\n').replace(/\.gitkeep\s/, '') +
      '\n'
    );

    diffFile.write(diffFileContent, (err) => {
      if(err){
        console.log(err.message);
      }
    });

  } catch(error){
    console.log(error);
  }
};

module.exports = {
  testCron,
  refreshAllMaterializedViews,
  dumpDatabase,
  diffUploads,
};
