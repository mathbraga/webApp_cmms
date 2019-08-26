const express = require('express');
const router = express.Router();
const { Client } = require('pg')

const client = new Client({
  user: process.env.DB_ADMIN,
  host: process.env.DB_HOST,
  database: process.env.DB_DBNAME,
  password: process.env.DB_PASS,
  port: process.env.DB_PORT,
});

router.post('/', (req, res) => {
  client.connect();
  client.query('SELECT public.register_user($1, $2, $3, $4)', [req.body.firstName, req.body.lastName, req.body.email, req.body.password], (err, data) => {
    client.end();
    if(err){
      console.log('Erro');
      res.status(500).end();
    } else {
      console.log('New user:' + JSON.stringify(data));
      res.json(data);
    }
  });
});

module.exports = router;