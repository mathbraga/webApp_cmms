const express = require('express');
const router = express.Router();
const nodemailer = require('nodemailer');

async function email(hostname) {
  
  if(hostname === '172.30.49.152'){
    // Generate test SMTP service account from ethereal.email
    // Only needed if you don't have a real mail account for testing
    // let testAccount = await nodemailer.createTestAccount();

    // create reusable transporter object using the default SMTP transport
    const transporter = nodemailer.createTransport({
      host: 'smtp.senado.leg.br',
      port: 587,
      secure: false,
      proxy: process.env.http_proxy,
      tls: {
        // do not fail on invalid certs
        rejectUnauthorized: false
      },
      auth: {
          user: 'hzlopes@senado.leg.br',
          pass: ''
      }
    });

    // send mail with defined transport object
    let info = await transporter.sendMail({
      from: 'hzlopes@senado.leg.br', // sender address
      to: 'hzlopes@senado.leg.br', // list of receivers
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



router.get('/', (req, res, next) => {

  email(req.hostname).catch(console.error);

  res.json({m: 'email route'});

});

module.exports = router;