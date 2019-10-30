const express = require('express');
const router = express.Router();
const http = require('http');

// PARA MOSTRAR IMAGENS DO REDMINE:
// <img src='http://redminesf.senado.gov.br/redmine/attachments/download/197482/SF-00275.jpeg'/>

// URL PARA BAIXAR PÁGINAS DAS DIRETRIZES DE ARQ E ENG:
// http://redminesf.senado.gov.br/redmine/projects/darqeng/wiki/TITLE-DA-PÁGINA.json
// 
// OBS 1: Como resultado, há um JSON com a key 'text', que contém todo o conteúdo da página
// OBS 2: TITLE-DA-PÁGINA É O CÓDIGO HUMAN-FRIENDLY DA PÁGINA
// EXEMPLOS:
// SF-00001 --> especificação técnica com código SF-00001
// EDPR-000 --> diretrizes e normas para o Ed. Principal
// Lei_Federal_999 --> página com informações e links para a Lei Federal 999


router.get('/', (request, response, next) => {
  http.get(
    'http://redminesf.senado.gov.br/redmine/projects/darqeng/wiki/index.json',
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
        // console.log(JSON.stringify(parsedData));

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