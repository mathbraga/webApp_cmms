const express = require('express');
const router = express.Router();
const { Client } = require('pg')

const client = new Client({
  user: 'postgres',
  host: '172.30.49.152',
  database: 'cmms',
  password: '123456',
  port: 5432,
});

router.post('/', (req, res) => {
  client.connect();
  client.query('SELECT public.register_user($1, $2, $3, $4)', [req.body.firstName, req.body.lastName, req.body.email, req.body.password], (err, data) => {
    client.end();
    if(err){
      console.log('Erro');
      res.json({'erro': 'mensagem'});
    } else {
      console.log('New user:' + JSON.stringify(data));
      res.json(data);
    }
  });
});

module.exports = router;