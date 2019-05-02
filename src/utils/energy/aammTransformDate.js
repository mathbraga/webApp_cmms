export default function aammTransformDate(date){
  // Inputs:
  // date (string): must be in mm/yyyy format
  //
  // Output:
  // date (string): same input date, but in yymm format
  //
  // Purpose:
  // Transform initialDate and finalDate inputs from FormDates
  // to aformat compatible with the sort key of the table in the database

  return date.slice(5) + date.slice(0, 2);
}