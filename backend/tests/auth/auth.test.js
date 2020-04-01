const util = require('util');
const exec = util.promisify(require('child_process').exec);
const path = require('path');
const paths = require('../../paths');

describe('Authentication tests', () => {

  const loginURL = path.join('http://localhost:3001', paths.auth, paths.login);
  const logoutURL = path.join('http://localhost:3001', paths.auth, paths.logout);
  const curlLoginSuccess = 
`curl \
-X POST \
-H 'Content-Type: application/json' \
-d '{"email": "hzlopes@senado.leg.br", "password": "123456"}' \
${loginURL}`
;
  const curlLoginFail = 
  `curl \
  -X POST \
  -H 'Content-Type: application/json' \
  -d '{"email": "hzlopes@senado.leg.br", "password": "abcdef"}' \
  ${loginURL}`
;
const curlLogout = `curl -X GET ${logoutURL}`;

  test('Login success', async () => {
    await expect(exec(curlLoginSuccess)).resolves.toMatchObject({
      stdout: expect.stringMatching(/loginsuccess.*true/i)
    });
  });

  test('Login fail', async () => {
    await expect(exec(curlLoginFail)).resolves.toMatchObject({
      stdout: expect.stringMatching(/unauthorized/i)
    });
  });

  test('Logout', async () => {
    await expect(exec(curlLogout)).resolves.toMatchObject({
      stdout: expect.stringMatching(/logoutsuccess.*true/i)
    });
  });

});
