const taskAttributes = '(999,1,1,1,,1,,"title","description",,,,,,,,,,1,"2019-12-01","2019-12-01")';

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

  insertTaskContractFailure: [
    taskAttributes,
    [1],
    [3], // supplyid = 3 belongs to contractid = 2
    [1], // qty ok
    null,
  ],

};

module.exports = inputs;
