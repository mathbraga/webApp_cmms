// Initialization and imports
const express = require('express');
const app = express();
const port = 3001;
const middleware = require('./middleware')
const cors = require('cors');
const { postgraphile } = require("postgraphile");

// Requiring routes
const cebRoutes   = require('./routes/ceb');
const caesbRoutes = require('./routes/caesb');
const assetRoutes = require('./routes/assets');
const woRoutes    = require('./routes/wos');

// Middlewares
app.use(cors());
// app.use(middleware);
app.use(express.json());
app.use(
  postgraphile(
    process.env.DATABASE_URL || "postgres://hzlopes:123456@localhost:5432/cmms",
    "public",
    {
      // Check other options at:
      // https://www.graphile.org/postgraphile/usage-library/#api-postgraphilepgconfig-schemaname-options
      watchPg: true,
      graphiql: true,
      enhanceGraphiql: true,
    }
  )
);

// Using routes
app.use("/energia", cebRoutes);
app.use("/agua", caesbRoutes);
app.use("/ativos", assetRoutes);
app.use("/manutencao/os", woRoutes);

// Listen for connections on specified port
app.listen(port, () => console.log(`App listening on port ${port}!`));