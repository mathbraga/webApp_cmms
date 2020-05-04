const util = require('util');
const exec = util.promisify(require('child_process').exec);
const path = require('path');
const paths = require('../../paths');
const { reqSuccess, reqSuccessWithFiles, reqFailNoAssets, supertestReq } = require('./reqs');
const request = require('supertest');
const app = require('../../app');
const pgPool = require('../../db');

describe('Task tests', () => {
  
  afterAll(async () => {
    await pgPool.end();
  });



  // const url = path.join('http://localhost:3001', paths.db);
  // const upload = __dirname + '/test.txt';
  // const curlSuccess = `curl -X POST -H 'Content-Type: application/json' -d '${reqSuccess}' ${url}`;
  // const curlFailNoAssets = `curl -X POST -H 'Content-Type: application/json' -d '${reqFailNoAssets}' ${url}`
  // const curlSuccessWithFiles = `curl -X POST -F operations='${reqSuccessWithFiles}' -F map='{ "0": ["variables.files.0"] }' -F 0=@${upload} ${url}`;

  // test('Insert task success', async () => {
  //   await expect(exec(curlSuccess)).resolves.toMatchObject({
  //     stdout: expect.stringMatching(/\"id\":\d+/)
  //   });
  // });

  // test('Insert task fail (no assets)', async () => {
  //   await expect(exec(curlFailNoAssets)).resolves.toMatchObject({
  //     stdout: expect.stringMatching(/\$assets/i)
  //   });
  // });

  // test('Insert task and upload files success', async () => {
  //   await expect(exec(curlSuccessWithFiles)).resolves.toMatchObject({
  //     stdout: expect.stringMatching(/\"id\":\d+/)
  //   });
  // });

  test('supertest', async () => {
    let res = await request(app)
      .post('/db')
      .set('Accept', 'application/json')
      .send(supertestReq)
    console.log(res)
  })

});
