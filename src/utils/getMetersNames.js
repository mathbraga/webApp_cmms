export default function getMetersNames(problem, meters){
  let metersNames = [];
  problem.meters.forEach(problemMeter => {
    meters.forEach(meter => {
      if(problemMeter === (meter.med.N + meter.tipomed.N*100)){
        metersNames.push(meter.idceb.S);
      }
    });
  });
  return metersNames;
}