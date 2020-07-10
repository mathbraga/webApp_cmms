// Usage instructions:
// https://dev.to/petereysermans/installing-a-node-js-application-as-a-windows-service-28j7

const Service = require('node-windows').Service;

const scriptPathname = __dirname + '\\server.js';

// Create a new service object
const svc = new Service({
  name:'CMMS',
  description: 'CMMS web application as Windows Service',
  script: scriptPathname,
  // nodeOptions: [
  //   '--require dotenv/config',
  // ],
  // scriptOptions: [
  //   '',
  // ],
  env: [
    { name: 'NODE_ENV',     value: 'production' },
    { name: 'HTTP_PORT',    value: '3001' },
    { name: 'PGUSER',       value: 'postgres' },
    { name: 'PGHOST',       value: 'localhost' },
    { name: 'PGDATABASE',   value: 'db_dev' },
    { name: 'PGPASSWORD',   value: '123456' },
    { name: 'PGPORT',       value: '3001' },
    { name: 'CRON_DIFF',    value: '' },
    { name: 'CRON_DUMP',    value: '' },
    { name: 'CRON_REFRESH', value: '' },
    { name: 'CRON_TEST',    value: '' },
  ],
});

// Listen for the "install" event, which indicates the
// process is available as a service.
svc.on('install', () => {
  svc.start();
});

// Listen for the "uninstall" event so we know when it's done.
svc.on('uninstall', () => {
  console.log('Uninstall complete.');
  console.log('The service exists: ', svc.exists);
});

module.exports = svc;
