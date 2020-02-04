export default function populateStateEditForm(baseState, itemData, editMode, customState) {
  if (!editMode) return baseState;
  const result = {};
  Object.keys(baseState).forEach((key) => result[key] = itemData ? itemData[key] : "");
  if (customState) {
    return customState(itemData, result);
  }
  return result;
}