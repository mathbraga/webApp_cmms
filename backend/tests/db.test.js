const { pgPool } = require('../db');

describe('Test all db functions', () => {
  
  afterAll(async () => {
    await pgPool.end();
  });

  beforeEach(async () => {
    await pgPool.query('begin');
  });

  afterEach(async () => {
    await pgPool.query('rollback');
  });

  test('Execute db function successfully', async () => {
    const result = await pgPool.query('select now()');
    expect(result.rows.length).not.toBe(0);
  });

  test('Execute db function unsuccessfully', async () => {
    await expect(pgPool.query('select non_existent_function()')).rejects.toThrow();
  });

});
