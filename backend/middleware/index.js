function middleware(req, res, next){

  const date = new Date();

  // Log
  console.log(
    '\n\n\n\n----------------------------------------------------------------------------------------------' +
    '\n' +
    'ORIGIN ' + req.ip +
    '    REQUESTED PATH: ' + req.path +
    '    DATE: ' + date.getDate() + '/' + (parseInt(date.getMonth(), 10) + 1).toString() + '/' + date.getUTCFullYear() +
    '    TIME: ' + date.getHours() + ':' + date.getMinutes() + ':' + date.getSeconds() +
    '\n\n' +
    'req user: ' + JSON.stringify(req.user) +
    '\n\n' +
    req.session.isNew +
    '\n\n' +
    'req session: ' + JSON.stringify(req.session) +
    '\n\n'
  );

  // Call next
  next();
}

module.exports = middleware;