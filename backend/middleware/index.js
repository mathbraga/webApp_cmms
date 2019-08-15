function middleware(req, res, next){
  
  // Log request
  // let date = new Date;
  // console.log("\n\nRequest to path " + req.path + " from host " + req.hostname + " at " + date.getHours() + ":" + date.getMinutes() + ":" + date.getSeconds());
  // console.log('\n\nreq.body:\n' + JSON.stringify(req.body));
  // var credentials = req.header('Authorization').split(' ')[1];
  // req.user = {};
  // req.user.username = credentials.split(':')[0];
  // req.user.password = credentials.split(':')[1];
  // console.log('\n\nauth:\n' + JSON.stringify(req.user));
  // // console.log('req.cookies: ' + JSON.stringify(req.cookies))
  // console.log('req.signedCookies: ' + JSON.stringify(req.signedCookies))

  // Set headers
  // res.append({
  //   'Access-Control-Allow-Origin': '*',
  //   'Access-Control-Allow-Headers': 'Content-Type',
  // });

  // Call next
  next();
}

module.exports = middleware;