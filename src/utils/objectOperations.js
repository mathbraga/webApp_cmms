function applyFuncToAttr(listObjects, attr, func) {
  let values = [];
  let answer = 0;
  listObjects.forEach(item => {
    if (item[attr] > 0) values.push(item[attr]);
  });
  try {
    if (attr === "dmp") console.log(values);
    answer = func(...values);
    if (attr === "dmp") console.log(answer);
  } catch {
    console.log("applyFuncToAttr: could not apply the function.");
  }
  return answer;
}

export { applyFuncToAttr };
