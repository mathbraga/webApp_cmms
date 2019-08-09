function middleware(req, res, next){
  
  // Log request
  console.log("Request to path " + req.path + " from host " + req.ip);
  
  // Set headers
  // res.set({
  //   'Access-Control-Allow-Origin': '*',
  //   'Access-Control-Allow-Headers': 'Content-Type'
  // });

  // Call next
  next();
}

module.exports = middleware;