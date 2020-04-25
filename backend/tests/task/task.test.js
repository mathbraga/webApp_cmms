const util = require('util');
const exec = util.promisify(require('child_process').exec);
const path = require('path');
const paths = require('../../paths');
const { reqSuccess, reqSuccessWithFiles, reqFailNoAssets } = require('./reqs');
//
const supertest = require('supertest');
const app = require("../../app");
const request = supertest(app);

describe('Task tests', () => {
  
  const url = path.join('http://localhost:3001', paths.db);
  const upload = __dirname + '/test.txt';
  const curlSuccess = `curl -X POST -H 'Content-Type: application/json' -d '${reqSuccess}' ${url}`;
  const curlFailNoAssets = `curl -X POST -H 'Content-Type: application/json' -d '${reqFailNoAssets}' ${url}`
  const curlSuccessWithFiles = `curl -X POST -F operations='${reqSuccessWithFiles}' -F map='{ "0": ["variables.files.0"] }' -F 0=@${upload} ${url}`;

  beforeAll(() => {
    exec("nodemon", (error, stdout, stderr) => {
      if (error) {
          console.log(`error: ${error.message}`);
          return;
      }
      if (stderr) {
          console.log(`stderr: ${stderr}`);
          return;
      }
      console.log(`stdout: ${stdout}`);
    });
  })

//server related tests

  test('Server response failure', async () => {
    const response = await request.get('/');
    expect(response.status).toBe(404);
  });

//--------------------


  test('Insert task success', async () => {
    await expect(exec(curlSuccess)).resolves.toMatchObject({
      stdout: expect.stringMatching(/\"id\":\d+/)
    });
  });

  test('Insert task fail (no assets)', async () => {
    await expect(exec(curlFailNoAssets)).resolves.toMatchObject({
      stdout: expect.stringMatching(/\$assets/i)
    });
  });

  test('Insert task and upload files success', async () => {
    await expect(exec(curlSuccessWithFiles)).resolves.toMatchObject({
      stdout: expect.stringMatching(/\"id\":\d+/)
    });
  });

});
