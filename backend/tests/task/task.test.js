const util = require('util');
const exec = util.promisify(require('child_process').exec);
const path = require('path');
const { pgPool } = require('../../db');
const inputs = require('./inputs');
const paths = require('../../paths');
const { reqSuccess, reqSuccessWithFiles } = require('./reqs');

describe('Test task functions', () => {
  
  const url = path.join('http://localhost:3001', paths.db);
  const upload = __dirname + '/test.txt';
  const curlSuccess = `curl -X POST -H 'Content-Type: application/json' -d '${reqSuccess}' ${url}`;
  const curlSuccessWithFiles = `curl -X POST -F operations='${reqSuccessWithFiles}' -F map='{ "0": ["variables.files.0"] }' -F 0=@${upload} ${url}`;

  // INSERT
  test('insert_task OK', async () => {
    await expect(exec(curlSuccess)).resolves.toMatchObject({stdout: expect.stringMatching(/\"id\":\d+/)});
  });

  // FILE UPLOAD
  test('upload file', async () => {
    await expect(exec(curlSuccessWithFiles)).resolves.toMatchObject({stdout: expect.stringMatching(/\"id\":\d+/)});
  });

});
