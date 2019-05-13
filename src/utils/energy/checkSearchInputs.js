export default function checkSearchInputs(initialDate, finalDate, oneMonth){
  
  // Generate currentMonth and currentYear for comparison
  let today = new Date();
  let currentMonth = today.getMonth(); // January is 0 ... December is 11
  let currentYear = today.getFullYear().toString();
  if(currentMonth < 10){
    currentMonth = "0" + currentMonth.toString();
  } else {
    currentMonth = currentMonth.toString();
  }
 
  // initialDate check
  // These conditions are applied for both cases (one month or period)
  if(
    initialDate.length < 7 ||                                                       // Incomplete input
    initialDate.slice(0, 2) > "12" ||                                               // Non-existent month
    initialDate.slice(0, 2) === "00" ||                                             // Non-existent month
    initialDate.slice(3) < "2017" ||                                                // Non-existent year in database
    initialDate.slice(3) > currentYear ||                                           // Non-existent year in database
    initialDate.slice(3) === currentYear && initialDate.slice(0, 2) > currentMonth  // Non-existent month in database
  ){
    return false;
  } else {
    
    // finalDate check
    // These conditions are applied only for period case
    if(!oneMonth){
      if(
      initialDate === finalDate ||                                                                      // Same dates
      finalDate.length < 7 ||                                                                           // Incomplete input
      finalDate.slice(0, 2) > "12" ||                                                                   // Non-existent month
      finalDate.slice(0, 2) === "00" ||                                                                 // Non-existent month
      finalDate.slice(3) < "2017" ||                                                                    // Non-existent year in database
      finalDate.slice(3) > currentYear ||                                                               // Non-existent year in database
      finalDate.slice(3) === currentYear && finalDate.slice(0, 2) > currentMonth ||                     // Non-existent month in database
      initialDate.slice(3) > finalDate.slice(3) ||                                                      // initialDate after finalDate (year check)
      initialDate.slice(3) === finalDate.slice(3) && initialDate.slice(0, 2) > finalDate.slice(0, 2)  // initialDate after finalDate (same year, month check)
      ) {
        return false;
      }
    } else {
      return true;
    }
  return true;
  }
}