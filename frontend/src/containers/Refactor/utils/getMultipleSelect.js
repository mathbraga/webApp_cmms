export default function getMultipleSelect(options){
  const n = options.length;
  const list = [];
  for (let i = 0; i < n; i++) {
    if (options[i].selected) {
      list.push(Number(options[i].value));
    }
  }
  return list.length > 0 ? list : null;
};