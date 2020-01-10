const taskAttributes = '(,1,1,1,,1,,"title","description",,,,,,,,,,,,)';

const inputs = {

  // [ $1: attributes, $2: assets, $3: supplies, $4: qty, $5: files metadata ]

  ok: [
    taskAttributes,
    [1],
    null,
    null,
    null,
  ],

  failNoAssets: [
    taskAttributes,
    null,
    null,
    null,
    null,
  ],

  failLargeQty: [
    taskAttributes,
    [1],
    [1],
    [999], // qty > balance for supply_id = 1
    null,
  ],

  failDecimals: [
    taskAttributes,
    [1],
    [76],
    [1.5], // supply_id = 76 does not allow decimals
    null,
  ],

  failContracts: [
    taskAttributes,
    [1],
    [3], // supply_id = 3 belongs to contractid = 2
    [1],
    null,
  ],

};

module.exports = inputs;
