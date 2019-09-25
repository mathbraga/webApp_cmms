const client = require('../pgclient');
const CronJob = require('cron').CronJob;

// client.connect(); // Client already defined in auth route

module.exports = new CronJob(
  '* * * * * *',
  async function() {
    let data;
      try {
        data = await client.query('select now()');
      }
      catch (error) {
        console.log(error)
      }
    console.log(data.rows[0])
  },
  null,
  true,
  'America/Sao_Paulo'
);