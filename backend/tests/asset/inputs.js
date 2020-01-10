const assetAttributesSuccess = '(,"SF","name",,1,,,,,,,)';
const assetAttributesCategoryFailure = '(,"SF","name",,2,,,,,,,)';

const inputs = {

  insertAssetSuccess: [
    assetAttributesSuccess, // asset attributes
    [1], // top id
    null, // parent id
  ],
  
  insertAssetCategoryFailure: [
    assetAttributesCategoryFailure, // asset attributes with category = 2 (appliance)
    [1], // top id
    null, // parent id
  ],
  
  insertAssetTopIdFailure: [
    assetAttributesSuccess, // asset attributes
    [2], // top id
    null, // parent id
  ],

}

module.exports = inputs;