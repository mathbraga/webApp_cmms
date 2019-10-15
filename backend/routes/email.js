const express = require('express');
const router = express.Router();
const nodemailer = require('nodemailer');

async function email() {

  // create reusable transporter object using the default SMTP transport
  const transporter = nodemailer.createTransport({
    host: 'smtps.senado.leg.br',
    port: 465,
    secure: true,
    proxy: process.env.http_proxy,
    auth: {
        user: 'hzlopes',
        pass: process.env.EMAIL_PASS,
    },
    tls: {
      rejectUnauthorized: false,
    },
    logger: true,
    debug: true,
  });

  // send mail with defined transport object
  let info = await transporter.sendMail({
    from: process.env.EMAIL_FROM,
    to: process.env.EMAIL_TO,
    subject: 'Hello',
    text: 'Hello world.',
  });

  console.log('Message sent: %s', info.messageId);

}

router.get('/', (req, res, next) => {

  email().catch(console.error);

  res.json({m: 'email route'});

});

module.exports = router;