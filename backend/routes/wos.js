const express = require('express');
const router = express.Router();
const db = require('../dbConnect');

router.get('/', (req, res) => {
  db.any('SELECT * FROM get_all_work_orders()')
  .then(data => {
    res.json(data);
  })
  .catch(error => {
    res.json({erro: "erro na route /manutencao/os"});
  });
});

router.get('/view', (req, res) => {
  console.log('\nreq.query:')
  console.log(req.query);
  db.one("SELECT * FROM get_work_order($1)", [req.query.id])
  .then(data => {
    console.log('\nwork order:');
    console.log(data);
    res.json(data);
  })
  .catch(error => {
    res.json({erro: "erro na route /manutencao/os/view"});
  });
});

module.exports = router;