const util = require('util');
const exec = util.promisify(require('child_process').exec);
const path = require('path');
const { pgPool } = require('../../db');
const inputs = require('./inputs');
const paths = require('../../paths');
const gql = require('./gql');

describe('Test task functions', () => {
  
  const url = path.join('http://localhost:3001', paths.db);
  const upload = __dirname + '/test.txt';
  const curl = `curl -X POST -F operations='${gql}' -F map='{ "0": ["variables.files.0"] }' -F 0=@${upload} ${url}`;

  // Setup and teardown
  afterAll(async () => {
    await pgPool.end();
  });
  beforeEach(async () => {
    await pgPool.query('begin');
    await pgPool.query('set local auth.data.person_id to 0');
  });
  afterEach(async () => {
    await pgPool.query('rollback');
  });

  // INSERT
  const INSERT_TASK_QUERY = 'select * from insert_task($1, $2, $3, $4, $5)';

  test.skip('insert_task OK', async () => {
    await expect(pgPool.query(INSERT_TASK_QUERY, inputs.ok)).resolves.toMatchObject({ rows: [{ result: expect.any(Number) }]});
  });
  test.skip('insert_task fails (no asset selected)', async () => {
    await expect(pgPool.query(INSERT_TASK_QUERY, inputs.failNoAssets)).rejects.toThrow(/CMMS: ERRO 1/);
  });
  test.skip('insert_task fails (supply qty larger than available)', async () => {
    await expect(pgPool.query(INSERT_TASK_QUERY, inputs.failLargeQty)).rejects.toThrow(/CMMS: ERRO 2/);
  });
  test.skip('insert_task fails (decimals not allowed)', async () => {
    await expect(pgPool.query(INSERT_TASK_QUERY, inputs.failDecimals)).rejects.toThrow(/CMMS: ERRO 3/);
  });
  test.skip('insert_task fails (contracts do not match)', async () => {
    await expect(pgPool.query(INSERT_TASK_QUERY, inputs.failContracts)).rejects.toThrow(/CMMS: ERRO 4/);
  });

  // MODIFY
  const MODIFY_TASK_QUERY = 'select * from modify_task($1, $2, $3, $4, $5)';

  test.skip('modify_task OK', async () => {
    await expect(pgPool.query(MODIFY_TASK_QUERY, inputs.ok)).resolves.toMatchObject({ rows: [{ result: expect.any(Number) }]});
  });
  test.skip('modify_task fails (no asset selected)', async () => {
    await expect(pgPool.query(MODIFY_TASK_QUERY, inputs.failNoAssets)).rejects.toThrow(/CMMS: ERRO 1/);
  });
  test.skip('modify_task fails (supply qty larger than available)', async () => {
    await expect(pgPool.query(MODIFY_TASK_QUERY, inputs.failLargeQty)).rejects.toThrow(/CMMS: ERRO 2/);
  });
  test.skip('modify_task fails (decimals not allowed)', async () => {
    await expect(pgPool.query(MODIFY_TASK_QUERY, inputs.failDecimals)).rejects.toThrow(/CMMS: ERRO 3/);
  });
  test.skip('modify_task fails (contracts do not match)', async () => {
    await expect(pgPool.query(MODIFY_TASK_QUERY, inputs.failContracts)).rejects.toThrow(/CMMS: ERRO 4/);
  });

  // FILE UPLOAD
  test('upload file', async () => {
    await expect(exec(curl)).resolves.toMatchObject({stdout: expect.stringMatching(/\"id\":\d+/)});
  });

});
