const { pgPool } = require('../../db');
const inputs = require('./inputs');

describe('Test asset related functions', () => {

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
    const INSERT_ASSET_QUERY = 'select * from insert_asset($1, $2, $3)';

    test('insert asset OK', async () => {
        await expect(pgPool.query(INSERT_ASSET_QUERY, inputs.insertAssetSuccess)).resolves.toMatchObject({ rows: [{ result: expect.any(Number) }]});
    });
    test('insert asset ERROR: Invalid category type.', async () => {
        await expect(pgPool.query(INSERT_ASSET_QUERY, inputs.insertAssetCategoryFailure)).rejects.toThrow(/5/);
    });
    test('insert asset ERROR: Invalid Top Id.', async () => {
        await expect(pgPool.query(INSERT_ASSET_QUERY, inputs.insertAssetTopIdFailure)).rejects.toThrow(/6/);
    });

    // MODIFY
    test.skip('Modify asset OK', async () => {
        await expect(pgPool.query(MODIFY_ASSET_QUERY, inputs.insertAssetSuccess)).resolves.toMatchObject({ rows: [{ result: expect.any(Number) }]});
    });
    test.skip('Modify asset ERROR: Invalid category type.', async () => {
        await expect(pgPool.query(MODIFY_ASSET_QUERY, inputs.insertAssetCategoryFailure)).rejects.toThrow(/5/);
    });
    test.skip('Modify asset ERROR: Invalid Top Id.', async () => {
        await expect(pgPool.query(MODIFY_ASSET_QUERY, inputs.insertAssetTopIdFailure)).rejects.toThrow(/6/);
    });

});
