const util = require('util');
const exec = util.promisify(require('child_process').exec);
const CronJob = require('cron').CronJob;
const pgClient = require('../pg');

module.exports = new CronJob({
  cronTime: '* * * * * *',
  onTick: async function() {
    
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
  onComplete: null,
  start: true,
  timezone: 'America/Sao_Paulo',
});
