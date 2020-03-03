export default function populateStateEditForm(baseState, itemData, editMode, customState) {
  const result = {}
  if (editMode) {
    Object.keys(baseState).forEach((key) => result[key] = (itemData || itemData[key]) ? itemData[key] : baseState[key]);
  }
  if (customState) {
    return customState(itemData, result);
  }
  return result;
}