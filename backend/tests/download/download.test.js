const util = require('util');
const exec = util.promisify(require('child_process').exec);
const path = require('path');
const paths = require('../../paths');

describe('Download tests', () => {

  const downloadURL = path.join(
    'http://localhost:3001',
    paths.files,
    "de741848-5e90-4c5e-8699-78aca9b37aba",
    "test.txt"
  );
  const curlDownload = `curl -X GET ${downloadURL}`;
  const curlStatic = `curl -I http://localhost:3001/images/test.jpeg`;

  test('Download', async () => {
    await expect(exec(curlDownload)).resolves.toMatchObject({
      stdout: expect.stringMatching(/upload and download/i)
    });
  });

  test('Static files', async () => {
    await expect(exec(curlStatic)).resolves.toMatchObject({
      stdout: expect.stringMatching(/200 OK/i)
    });
  });

});
