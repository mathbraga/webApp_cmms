const path = require('path');
const paths = require('../../paths');
const got = require('got');

describe('Download tests', () => {

  const downloadURL = path.join(
    'http://localhost:3001',
    paths.files,
    "de741848-5e90-4c5e-8699-78aca9b37aba",
    "test.txt"
  );

  test('Download', async () => {
    const response = await got.get(downloadURL);
    expect(response.statusCode).toBe(200);
  });

  test('Static files', async () => {
    const response = await got.get('http://localhost:3001/images/test.jpeg');
    expect(response.statusCode).toBe(200);
  });

});
