// Usage instructions:
// https://dev.to/petereysermans/installing-a-node-js-application-as-a-windows-service-28j7

var Service = require('node-windows').Service;

// Create a new service object
var svc = new Service({
  name:'Node.js - CMMS web app',
  description: 'Node.js - CMMS web application as Windows Service',
  script: 'D:\\USERS\\hzlopes\\Desktop\\code\\cmms\\backend\\server.js',
  nodeOptions: [
    '--require dotenv/config',
  ],
  scriptOptions: [
    '',
  ],
  env: {
    name: 'dotenv_config_path',
    value: '.env.pro'
  }
});

// Listen for the "install" event, which indicates the
// process is available as a service.
svc.on('install',function(){
  svc.start();
});

// Listen for the "uninstall" event so we know when it's done.
svc.on('uninstall',function(){
  console.log('Uninstall complete.');
  console.log('The service exists: ', svc.exists);
});

module.exports = svc;
