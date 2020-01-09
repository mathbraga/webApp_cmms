const { pgPool } = require('../db');
const { INSERT_TASK_QUERY } = require('./queries');
const inputs = require('./inputs');

describe('Test all db functions', () => {
  
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

  test('insert_task OK', async () => {
    await expect(pgPool.query(INSERT_TASK_QUERY, inputs.insertTaskSuccess)).resolves.toMatchObject({ rows: [{ result: expect.any(Number) }]});
  });

  test('insert_task fails (no asset selected)', async () => {
    await expect(pgPool.query(INSERT_TASK_QUERY, inputs.insertTaskFailure)).rejects.toThrow(/CMMS: ERRO 1/);
  });

  test('insert_task fails (supply qty larger than available)', async () => {
    await expect(pgPool.query(INSERT_TASK_QUERY, inputs.insertTaskQtyFailure)).rejects.toThrow(/CMMS: ERRO 2/);
  });

  // test('insert_task fails (decimals not allowed)', async () => {
  //   await expect(pgPool.query(INSERT_TASK_QUERY, inputs.insertTaskDecimalsFailure)).rejects.toThrow(/CMMS: ERRO 2/);
  // });

  test('insert_task fails (contracts do not match)', async () => {
    await expect(pgPool.query(INSERT_TASK_QUERY, inputs.insertTaskContractFailure)).rejects.toThrow(/CMMS: ERRO 4/);
  });

});
