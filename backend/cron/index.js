const { pgClient } = require('../configs');
const CronJob = require('cron').CronJob;
const util = require('util');
const exec = util.promisify(require('child_process').exec);

/* Documentation:
   Cron package: https://www.npmjs.com/package/cron
   Node: https://nodejs.org/dist/latest-v12.x/docs/api/
*/

module.exports = new CronJob(
  '0 * * * * *', // Every minute, when seconds = 0
  async function() {
    
    // Scheduled query to be sent to database:
    // let data;
    //   try {
    //     data = await pgClient.query('select now()');
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
  null,
  true,
  'America/Sao_Paulo'
);