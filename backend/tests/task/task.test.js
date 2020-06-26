const { reqSuccess, reqSuccessWithFile } = require('./reqs');
const got = require('got');

describe('Task tests', () => {

  const gotURL = 'http://localhost:3001/db';
  
  test('Insert task', async () => {
    const response = await got.post(gotURL, { json: reqSuccess, responseType: 'json' });
    expect(response.statusCode).toBe(200)
  });

  test('Insert task with file upload', async () => {
    const response = await got.post(gotURL, { body: reqSuccessWithFile, responseType: 'json' });
    expect(response.statusCode).toBe(200)
  });

});
