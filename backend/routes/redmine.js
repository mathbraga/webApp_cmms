const express = require('express');
const router = express.Router();
const http = require('http');

router.get('/', (request, response, next) => {
  http.get(
    'http://redminesf.senado.gov.br/redmine/projects/darqeng/wiki/SF-00001.json',
    {
      headers: {
        'X-Redmine-API-Key': 'aa1b1fb0b0b8f866342eb065645c3df8e3b5cc81'
      }
    },
    (res) => {
    const { statusCode } = res;
    const contentType = res.headers['content-type'];
  
    let error;
    if (statusCode !== 200) {
      error = new Error('Request Failed.\n' +
                        `Status Code: ${statusCode}`);
    } else if (!/^application\/json/.test(contentType)) {
      error = new Error('Invalid content-type.\n' +
                        `Expected application/json but received ${contentType}`);
    }
    if (error) {
      console.error(error.message);
      // Consume response data to free up memory
      res.resume();
      return;
    }
  
    res.setEncoding('utf8');
    let rawData = '';
    res.on('data', (chunk) => { rawData += chunk; });
    res.on('end', () => {
      try {
        const parsedData = JSON.parse(rawData);
        console.log(parsedData);

        // SEND JSON
        response.json(parsedData);

      } catch (e) {
        console.error(e.message);
      }
    });
  }).on('error', (e) => {
    console.error(`Got error: ${e.message}`);
  });
});

module.exports = router;