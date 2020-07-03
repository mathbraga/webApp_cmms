const path = require('path');
const paths = require('../../paths');
const got = require('got');

describe('Authentication tests', () => {

  const loginURL = path.join('http://localhost:3001', paths.login);
  const logoutURL = path.join('http://localhost:3001', paths.logout);

  test('Login success', async () => {
    const response = await got.post(
      loginURL,
      {
        json: {
          email: 'hzlopes@senado.leg.br',
          password: '123456',
        },
      }
    );
    expect(response.statusCode).toBe(200);
  });

  test('Login fail', async () => {
    const response = await got.post(
      loginURL,
      {
        json: {
          email: 'hzlopes@senado.leg.br',
          password: 'abcdef',
        },
        throwHttpErrors: false,
      }
    );
    expect(response.statusCode).toBe(401);
  });

  test('Logout', async () => {
    const response = await got.get(logoutURL);
    expect(response.statusCode).toBe(200);
  });

});
