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
  client.query('SELECT register_user($1, $2, $3, $4, $5, $6, $7, $8)', [
    req.body.email,
    req.body.name,
    req.body.surname,
    req.body.phone,
    req.body.department,
    req.body.contract,
    req.body.category,
    req.body.password
  ], (err, data) => {
    client.end();
    if(err){
      console.log('Erro');
      res.status(500).end();
    } else {
      console.log('New user:' + JSON.stringify(data));
      res.redirect('../login');
    }
  });
});

module.exports = router;