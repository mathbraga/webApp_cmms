const paths = require('./paths');
const { Client } = require('pg');
const util = require('util');
const exec = util.promisify(require('child_process').exec);

const corsConfig = {
  origin: true,
  credentials: true,
};

const staticConfig = {
  root: 'public',
  options: {}
};

const cookieSessionConfig = {
  name: 'cmms:session',
  keys: ['key0', 'key1', 'key2'],
  signed: true,
  httpOnly: true,
};

const pgConfig = {
  user: process.env.DB_ADMIN || 'postgres',
  host: process.env.DB_HOST || 'localhost',
  database: process.env.DB_DBNAME || 'dbname',
  password: process.env.DB_PASS || '123456',
  port: process.env.DB_PORT || 5432
};

const pgClient = new Client(pgConfig);
pgClient.connect();

const postgraphileConfig = {
  schemas: ['public'],
  options: { 
    watchPg: true,
    enableCors: false,
    graphqlRoute: paths.db,
    graphiql: true,
    graphiqlRoute: paths.graphiql,
    enhanceGraphiql: true,
    disableQueryLog: false,
    dynamicJson: true,
    showErrorStack: 'json',
    extendedErrors: ['hint', 'detail', 'errcode'],
    pgSettings: async req => {
      const [person_id, role] = req.session.passport ? req.session.passport.user.split('-') : ['0', 'visitor'];
      return {
        'role': role,
        'auth.data.person_id': person_id,
      }
    }
  }
};

const cronConfig = {
  cronTime: '0 * * * * *',
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
};

const multerConfig = {
  diskStorage: {
    destination: function (req, file, cb) {
      
      /* Example of file:
        {
          fieldname: 'avatar',
          originalname: 'originalnamefromfrontend.jpeg',
          encoding: '7bit',
          mimetype: 'image/jpeg'
        }
      */
  
    // console.log(file);
    let folder = 'files/'
      if(file.fieldname === 'image'){
        folder = 'public/images/';
      }
      cb(null, folder);
    },
    filename: function (req, file, cb) {
      cb(null, file.originalname);
    }
  },
  fields: [
    { name: 'image', maxCount: 1 },
    { name: 'files', maxCount: 10 },
  ],
};

module.exports = {
  corsConfig,
  staticConfig,
  cookieSessionConfig,
  pgConfig,
  pgClient,
  postgraphileConfig,
  cronConfig,
  multerConfig
};
