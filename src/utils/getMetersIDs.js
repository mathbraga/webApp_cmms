export default function getMetersIDs(problem, meters) {
  // Inputs:
  // problem (object): contains information generated by checkProblems function
  // meters (array): list of all meters
  //
  // Output:
  // metersIDs (array): list of IDs of meters that had problems to verify
  //
  // Purpose:
  // Provide meter ID ("human friendly" meter identification), instead of 'med' (attribute from database)
  
  let metersIDs = [];
  problem.meters.forEach(problemMeter => {
    meters.forEach(meter => {
      if (
        problemMeter ===
        parseInt(meter.med.N, 10) + 100 * parseInt(meter.tipomed.N, 10)
      ) {
        metersIDs.push(meter.idceb.S);
      }
    });
  });
  return metersIDs;
}
