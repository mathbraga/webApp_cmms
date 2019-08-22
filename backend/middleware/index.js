function middleware(req, res, next){

  // Logs
  console.log('\n\n\n\n-----------------------------\nREQUESTED PATH: ' + req.path);
  // console.log('new req session? : ' + req.session.isNew);
  // console.log('req session: ' + req.user);

  // Set headers
  res.set({
    'Access-Control-Allow-Origin': 'http://localhost:3000',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Access-Control-Allow-Credentials': true
  });

  // Call next
  next();
}

module.exports = middleware;