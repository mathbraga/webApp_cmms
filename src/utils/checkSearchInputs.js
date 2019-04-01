export default function checkSearchInputs(initialDate, finalDate, oneMonth){
  
  // Conditions both cases (one month or period) --> initialDate check
  if(
    initialDate.length < 7 ||           // Incomplete input
    initialDate.slice(0, 2) > "12" ||   // Non-existent month
    initialDate.slice(0, 2) === "00" || // Non-existent month
    initialDate.slice(3) < "2017" ||    // Non-existent year in database
    initialDate.slice(3) > "2019"       // Non-existent year in database
  ){
    return false;
  } else {
    
    // Special conditions for period --> finalDate check
    if (!oneMonth){
      if(
      finalDate.length < 7 ||           // Incomplete input
      finalDate.slice(0, 2) > "12" ||   // Non-existent month
      finalDate.slice(0, 2) === "00" || // Non-existent month
      finalDate.slice(3) < "2017" ||    // Non-existent year in database
      finalDate.slice(3) > "2019" ||    // Non-existent year in database
      // initialDate after finalDate (year check)
      initialDate.slice(3) > finalDate.slice(3) ||
      // initialDate after finalDate (same year, month check)
      (initialDate.slice(3) === finalDate.slice(3) && initialDate.slice(0, 2) > finalDate.slice(0, 2))
      ) {
        return false;
      }
    } else {
      return true;
    }
  return true;
  }
}