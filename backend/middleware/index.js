const nodemailer = require('nodemailer');

async function email(hostname) {
  
  if(hostname === '172.30.49.152'){
    // Generate test SMTP service account from ethereal.email
    // Only needed if you don't have a real mail account for testing
    // let testAccount = await nodemailer.createTestAccount();

    // create reusable transporter object using the default SMTP transport
    const transporter = nodemailer.createTransport({
      host: 'smtp.ethereal.email',
      port: 587,
      auth: {
          user: 'sophie.crist@ethereal.email',
          pass: 'r71qsfREgH2hKCfP2V'
      }
    });

    // send mail with defined transport object
    let info = await transporter.sendMail({
      from: 'sophie.crist@ethereal.email', // sender address
      to: 'sophie.crist@ethereal.email', // list of receivers
      subject: 'Hello ✔', // Subject line
      text: 'Hello world?', // plain text body
      html: '<b>Hello world?</b>' // html body
    });

    console.log('Message sent: %s', info.messageId);

    // Preview only available when sending through an Ethereal account
    console.log('Preview URL: %s', nodemailer.getTestMessageUrl(info));

  } else {
    console.log('not hz.')
  }
}



function middleware(req, res, next){

  email(req.hostname)
    .catch(console.error);

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