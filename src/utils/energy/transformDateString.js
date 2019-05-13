const monthList = {
  "01": "jan",
  "02": "fev",
  "03": "mar",
  "04": "abr",
  "05": "mai",
  "06": "jun",
  "07": "jul",
  "08": "ago",
  "09": "set",
  "10": "out",
  "11": "nov",
  "12": "dez"
};

function transformDateString(date) {
  return (
    monthList[date.toString().slice(2)] + "/20" + date.toString().slice(0, 2)
  );
}

function dateWithFourDigits(date) {
  // Transform "mm/yyyy" to "yymm"
  return date.slice(-2) + date.slice(0, 2);
}

export { transformDateString, dateWithFourDigits };
