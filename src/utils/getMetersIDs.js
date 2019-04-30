export default function getMetersIDs(problem, meters) {
  console.log("GetMetersIds:");
  console.log(problem);
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
