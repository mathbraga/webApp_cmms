export default function checkSearchInputs(initialDate, finalDate, month1, month2, oneMonth){
  
  // Check passed arguments
  if (
    // Conditions for one any case (one month or period)
    initialDate.length < 7 ||
    initialDate.slice(0, 2) > "12" ||
    month1 < "1701" ||
    // Special conditions for period
    !oneMonth && (month2 < month1) ||
    !oneMonth && (finalDate.length < 7)
  ) 
  {
    return false;
  } else {
    return true;
  }
}