const express = require('express');
const router = express.Router();
const db = require('../dbConnect');

router.get('/', (req, res) => {
  db.any('SELECT * FROM get_all_caesb_meters()')
  .then(data => {
    res.json(data);
  })
  .catch(error => {
    res.json({erro: "erro na route /agua"});
  });
});

router.get('/pesquisa', (req, res) => {
  console.log('\nreq.query:')
  console.log(req.query);
  db.any("SELECT * FROM get_caesb_bills($1, $2, $3)", [req.query.med, req.query.aamm1, req.query.aamm2])
  .then(data => {
    console.log('\ndata from database:');
    console.log(data);
    res.json(data);
  })
  .catch(error => {
    res.json({erro: "erro na route /agua/pesquisa"});
  });
});

module.exports = router;