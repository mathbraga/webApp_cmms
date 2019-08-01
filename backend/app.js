const express = require('express')
const app = express()
const port = 3001
const db = require('./pgpromiseInit');
/*
Database functions:
get_all_ceb_meters()
get_all_caesb_meters()
get_ceb_bills(med, aamm1, aamm2)
get_caesb_bills(med, aamm1, aamm2)
get_asset('id')
get_work_order(id)
get_all_assets()
get_all_work_orders()
*/

app.get('/allmeters', (req, res, next) => {
  res.set({
    'Access-Control-Allow-Origin': '*',
  });
  db.any('SELECT * FROM get_all_meters()')
  .then(data => {
    res.json(data);
  })
  .catch(error => {
    res.json({erro: "erro na query"});
  });
});

app.get('/allassets', (req, res, next) => {
  res.set({
    'Access-Control-Allow-Origin': '*',
  });
  db.any('SELECT * FROM get_all_assets()')
  .then(data => {
    res.json(data);
  })
  .catch(error => {
    res.json({erro: "erro na query"});
  });
});


app.get('/ceb', (req, res, next) => {
  console.log('\n');
  console.log('req.query:')
  console.log(req.query);
  console.log('\n');
  res.set({
    'Access-Control-Allow-Origin': '*',
  });

  db.any("SELECT * FROM get_ceb_bills($1, $2, $3)", [req.query.med, req.query.aamm1, req.query.aamm2])
  .then(data => {
    console.log('data:');
    console.log(data);
    res.json(data);
  })
  .catch(error => {
    res.json({erro: "erro na query"});
  });
});



app.get('/oneasset', (req, res, next) => {
  console.log('\n');
  console.log('req.query:')
  console.log(req.query);
  console.log('\n');
  res.set({
    'Access-Control-Allow-Origin': '*',
  });

  db.any("SELECT * FROM get_asset($1)", [req.query.id])
  .then(data => {
    console.log('data:');
    console.log(data);
    res.json(data);
  })
  .catch(error => {
    res.json({erro: "erro na query"});
  });
})


app.get('/onewo', (req, res, next) => {
  console.log('\n');
  console.log('req.query:')
  console.log(req.query);
  console.log('\n');
  res.set({
    'Access-Control-Allow-Origin': '*',
  });

  db.any("SELECT * FROM get_work_order($1)", [req.query.id])
  .then(data => {
    console.log('data:');
    console.log(data);
    res.json(data);
  })
  .catch(error => {
    res.json({erro: "erro na query"});
  });
})


app.get('/allwos', (req, res, next) => {
  console.log('\n');
  console.log('req.query:')
  console.log(req.query);
  console.log('\n');
  res.set({
    'Access-Control-Allow-Origin': '*',
  });

  db.any("SELECT * FROM get_all_work_orders()")
  .then(data => {
    console.log('data:');
    console.log(data);
    res.json(data);
  })
  .catch(error => {
    res.json({erro: "erro na query"});
  });
})

app.get('/search', (req, res, next) => {
  console.log('\n');
  console.log('req.query:')
  console.log(req.query);
  console.log('\n');
  res.set({
    'Access-Control-Allow-Origin': '*',
  });

  db.any("SELECT * FROM get_all_ceb_meters()")
  .then(data => {
    // console.log('data:');
    // console.log(data);
    res.json(data);
  })
  .catch(error => {
    console.log(error)
    res.json({erro: "erro na query"});
  });
})




app.listen(port, () => console.log(`App listening on port ${port}!`));