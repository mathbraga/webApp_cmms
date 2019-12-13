const util = require('util');
const exec = util.promisify(require('child_process').exec);
const CronJob = require('cron').CronJob;
const db = require('../db');

module.exports = new CronJob({
  cronTime: '* * * * * *',
  onTick: async function() {
    
    // Refresh materialized view:
    // let data;
    //   try {
    //     data = await db.query('refresh materialized view dashboard_data');
    //   }
    //   catch (error) {
    //     console.log(error);
    //   }
    // console.log('\n\nMaterialized view was refreshed.\n\n');

    // Scheduled query to be sent to database:
    // let data;
    //   try {
    //     data = await db.query('select now()');
    //   }
    //   catch (error) {
    //     console.log(error);
    //   }
    // console.log(data.rows[0]);
    
    // Scheduled bash command:
    // const { stdout, stderr } = await exec('pg_dump -f dumps/dump.sql -d ' + process.env.DB_DBNAME);
    // console.log('Scheduled pg_dump executed.')
    // console.log('stdout:', stdout);
    // console.log('stderr:', stderr);
  },
  onComplete: null,
  start: true,
  timezone: 'America/Sao_Paulo',
});
