export const baseState = {
  assetSf: "",
  name: "",
  latitude: "",
  longitude: "",
  description: "",
  area: "",
}

export function addNewCustomStates(itemData, currentState) {
  const result = { ...currentState, parent: null, context: null };
  result.parents = itemData
    ? itemData.parents
      .map((parent, index) => (parent && { context: itemData.contexts[index], parent, }))
      .filter(item => (item !== null))
    : [];
  return result;
}