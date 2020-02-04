export const baseState = {
  assetSf: "",
  name: "",
  description: "",
  manufacturer: "",
  serialnum: "",
  model: "",
  price: "",
}

export function addNewCustomStates(itemData, currentState) {
  const result = { ...currentState, parent: null, context: null };
  result.parents = itemData
    ? itemData.parents
      .map((parent, index) =>
        (parent &&
        {
          context: itemData.contexts[index],
          parent,
          id: `${parent.assetId}-${itemData.contexts[index].assetId}`
        }
        ))
      .filter(item => (item !== null))
    : [];
  return result;
}