function middleware(req, res, next){

  const date = new Date();

  // Log
  console.log(
    '\n' +
    '\n----------------------------------------------------------------------------------------------' +
    '\nORIGIN ' + req.ip +
    '\tREQUESTED PATH: ' + req.path +
    '\tDATE: ' + date.getDate() + '/' + (parseInt(date.getMonth(), 10) + 1).toString() + '/' + date.getUTCFullYear() +
    '\tTIME: ' + date.getHours() + ':' + date.getMinutes() + ':' + date.getSeconds() +
    '\nUSER: ' + JSON.stringify(req.user) +
    '\tNEW SESSION? ' + req.session.isNew +
    '\tSESSION: ' + JSON.stringify(req.session) +
    // '\nREQ.BODY: ' + JSON.stringify(req.body) +
    '\n----------------------------------------------------------------------------------------------' +
    '\n'
  );

  // Call next
  next();
}

module.exports = middleware;