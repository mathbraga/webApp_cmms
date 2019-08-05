// INITIALIZATION AND IMPORTS
const express = require('express');
const app = express();
const port = 3001;
// const db = require('./dbConnect');

// REQUIRING ROUTES
const cebRoutes   = require('./routes/ceb');
const caesbRoutes = require('./routes/caesb');
const assetRoutes = require('./routes/assets');
const woRoutes    = require('./routes/wos');

// MIDDLEWARE TO SET HTTP HEADERS
app.use(function(req, res, next){
  res.set({
    'Access-Control-Allow-Origin': '*',
  });
  next();
});

// USE EXPORTED ROUTERS
app.use("/energia", cebRoutes);
app.use("/agua", caesbRoutes);
app.use("/ativos", assetRoutes);
app.use("/manutencao/os", woRoutes);

// THIS ROUTE IS ONLY FOR QUICK TESTING OF BACKEND
app.get('/quicktest', (req, res, next) => {
  console.log('\nQuick test route.\n');
});

// LISTEN FOR CONNECTIONS ON SPECIFIED PORT
app.listen(port, () => console.log(`App listening on port ${port}!`));