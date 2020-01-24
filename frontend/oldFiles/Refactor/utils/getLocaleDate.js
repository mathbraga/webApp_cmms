export default function getLocaleDate(timestamp){
  const dateArr = timestamp.split('T')[0].split('-');
  return dateArr[2] + '/' + dateArr[1] + '/' + dateArr[0];
}