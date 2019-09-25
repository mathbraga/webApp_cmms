function middleware(req, res, next){

  const date = new Date();

  // Logs
  console.log('\n\n\n\n-----------------------------------------------------------------------');
  console.log(
    'HOST ' + req.ip +
    '    REQUESTED PATH: ' + req.path +
    '    TIME: ' + date.getHours() + ':' + date.getMinutes() + ':' + date.getSeconds() +
    '\n\n'
  );
  console.log('req user: ' + JSON.stringify(req.user));
  console.log(req.session.isNew);
  console.log('req session: ' + JSON.stringify(req.session));
  console.log('\n\n');

  // Call next
  next();
}

module.exports = middleware;