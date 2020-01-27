const assetAttributesSuccess =         '(1,"SF","name",,1,,,,,,,)';
const assetAttributesCategoryFailure = '(1,"SF","name",,2,,,,,,,)';

const inputs = {

  insertAssetSuccess: [
    assetAttributesSuccess, // asset attributes
    [1], // top id
    [2], // parent id
  ],
  
  insertAssetCategoryFailure: [
    assetAttributesCategoryFailure, // asset attributes with category = 2 (appliance)
    [1], // top id
    [2], // parent id
  ],
  
  insertAssetTopIdFailure: [
    assetAttributesSuccess, // asset attributes
    [2], // top id
    [3], // parent id
  ],

}

module.exports = inputs;