function middleware(req, res, next){

  // console.log(req)

  // Logs
  console.log('\n\n\n\n-----------------------------\nREQUESTED PATH: ' + req.path);
  // console.log('new req session? : ' + req.session.isNew);
  // console.log('req session: ' + req.user);

  console.log('LOGGING MIDDLEWARE FOR ALL ROUTES');
  console.log('req user: ' + JSON.stringify(req.user));
  console.log('New session?')
  // console.log(req.session.isNew);
  console.log('req session: ' + JSON.stringify(req.session));
  console.log('\n\n\n\nREQUEST\n')

  // Set headers
  // res.set({
  //   'Access-Control-Allow-Origin': 'http://localhost:3000',
  //   'Access-Control-Allow-Headers': 'Origin, X-Requested-With, Content-Type, Content-Length, Accept, Authorization, X-Apollo-Tracing',
  //   'Access-Control-Allow-Credentials': true,
  //   'Vary': 'Origin',
  //   'Access-Control-Allow-Methods': 'HEAD, POST, GET, OPTIONS, DELETE',
  // });

  // Call next
  next();
}

module.exports = middleware;