function middleware(req, res, next){
  
  // Log request
  let date = new Date;
  console.log("Request to path " + req.path + " from host " + req.hostname + " at " + date.getHours() + ":" + date.getMinutes() + ":" + date.getSeconds());
  console.log('req.body:\n' + JSON.stringify(req.body));
  // console.log('req.cookies: ' + JSON.stringify(req.cookies))
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