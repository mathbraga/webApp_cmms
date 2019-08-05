const express = require('express');
const router = express.Router();
const db = require('../dbConnect');

router.get('/', (req, res) => {
  db.any('SELECT * FROM get_all_assets()')
  .then(data => {
    res.json(data);
  })
  .catch(error => {
    res.json({erro: "erro na route /ativos"});
  });
});

router.get('/view', (req, res) => {
  console.log('\nreq.query:')
  console.log(req.query);
  db.one("SELECT * FROM get_asset($1)", [req.query.id])
  .then(data => {
    console.log('\nasset:');
    console.log(data);
    res.json(data);
  })
  .catch(error => {
    res.json({erro: "erro na route /ativos/view"});
  });
});

module.exports = router;