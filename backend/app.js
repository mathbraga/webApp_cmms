// Initialization and imports
const express = require('express');
const app = express();
const port = 3001;
const middleware = require('./middleware')
// Requiring routes
const cebRoutes   = require('./routes/ceb');
const caesbRoutes = require('./routes/caesb');
const assetRoutes = require('./routes/assets');
const woRoutes    = require('./routes/wos');

// Middlewares
app.use(middleware);
app.use(express.json());

// Using routes
app.use("/energia", cebRoutes);
app.use("/agua", caesbRoutes);
app.use("/ativos", assetRoutes);
app.use("/manutencao/os", woRoutes);

// Quick route for testing stuff
app.get('/quicktest', (req, res, next) => {
  console.log('\nQuick test route.\n');
  res.json({response: 'quick test ok'});
});

// Listen for connections on specified port
app.listen(port, () => console.log(`App listening on port ${port}!`));