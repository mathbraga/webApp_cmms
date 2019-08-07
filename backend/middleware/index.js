function middleware(req, res, next){
  
  // Logs request information for easier debugging
  console.log("Request to path " + req.path + " from host " + req.ip);
  
  // Set the necessary headers
  res.set({
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type'
  });

  // Call next
  next();
}

module.exports = middleware;