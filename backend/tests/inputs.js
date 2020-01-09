const taskAttributes = '(,1,1,1,,1,,"title","description",,,,,,,,,,,,)';

const inputs = {

  insertTaskSuccess: [
    taskAttributes, // task attributes
    [1], // assets
    null, // supplies ids
    null, // supplies qtys
    null, // files metadata
  ],

  insertTaskFailure: [
    taskAttributes,
    null,
    null,
    null,
    null,
  ],

  insertTaskQtyFailure: [
    taskAttributes,
    [1],
    [1],
    [999], // qty > available
    null,
  ],

  insertTaskDecimalsFailure: [
    taskAttributes,
    [1],
    [1],
    [1.5], // decimals not allowed for supply_id = 
    null,
  ],

  insertTaskContractFailure: [
    taskAttributes,
    [1],
    [3], // supplyid = 3 belongs to contractid = 2
    [1], // qty ok
    null,
  ],

};

module.exports = inputs;
