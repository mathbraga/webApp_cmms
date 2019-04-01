const monthList = {
  "01": "Jan",
  "02": "Fev",
  "03": "Mar",
  "04": "Abr",
  "05": "Mai",
  "06": "Jun",
  "07": "Jul",
  "08": "Ago",
  "09": "Set",
  "10": "Out",
  "11": "Nov",
  "12": "Dez"
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
