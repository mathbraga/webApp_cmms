// Initialization and imports
const express = require('express');
const app = express();
const port = 3001;
// const middleware = require('./middleware')
const cors = require('cors');
const db = require('./dbConnect');

// Requiring routes
const cebRoutes   = require('./routes/ceb');
const caesbRoutes = require('./routes/caesb');
const assetRoutes = require('./routes/assets');
const woRoutes    = require('./routes/wos');

/////////////////////////////////////////////////
var graphqlHTTP = require('express-graphql');
var { buildSchema } = require('graphql');
// Construct a schema, using GraphQL schema language
var schema = buildSchema(`
  type Query {
    hello: String
    soma(n1: Int!, n2: Int!): Int
  }
`);

// The root provides a resolver function for each API endpoint
var root = {
  hello: () => {
    return 'Hello world!';
  },
  soma: ({n1, n2}) => {
    return n1 + n2;
  }
};

/////////////////////////////////////////////////




// Middlewares
app.use(cors());
// app.use(middleware);
app.use(express.json());
app.use('/graphql', graphqlHTTP({
  schema: schema,
  rootValue: root,
  graphiql: true,
}));






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