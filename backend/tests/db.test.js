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

  test('Execute db function successfully', async () => {
    const result = await pgPool.query(INSERT_TASK_QUERY, inputs.insertTaskSuccess);
    expect(result.rows.length).not.toBe(0);
  });

  test('Execute db function unsuccessfully', async () => {
    await expect(pgPool.query(INSERT_TASK_QUERY, inputs.insertTaskFailure)).rejects.toThrow(/must be/);
  });

  test('Execute db function unsuccessfully', async () => {
    await expect(pgPool.query(INSERT_TASK_QUERY, inputs.insertTaskQtyFailure)).rejects.toThrow(/larger than/);
  });

  test('Execute db function unsuccessfully', async () => {
    await expect(pgPool.query(INSERT_TASK_QUERY, inputs.insertTaskContractFailure)).rejects.toThrow(/Contract/);
  });

});
