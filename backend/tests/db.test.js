const { pgPool } = require('../db');
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
    const result = await pgPool.query('select * from insert_task($1, $2, $3, $4, $5)', inputs.insertTaskSuccess);
    expect(result.rows.length).not.toBe(0);
  });

  test('Execute db function unsuccessfully', async () => {
    await expect(pgPool.query('select * from insert_task($1, $2, $3, $4, $5)', inputs.insertTaskFailure)).rejects.toThrow(/must be/);
  });

  test('Execute db function unsuccessfully', async () => {
    await expect(pgPool.query('select * from insert_task($1, $2, $3, $4, $5)', inputs.insertTaskQtyFailure)).rejects.toThrow(/larger than/);
  });

  test('Execute db function unsuccessfully', async () => {
    await expect(pgPool.query('select * from insert_task($1, $2, $3, $4, $5)', inputs.insertTaskContractFailure)).rejects.toThrow(/Contract/);
  });

});
