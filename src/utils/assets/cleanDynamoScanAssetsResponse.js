export default function cleanDynamoScanAssetsResponse(data){
  let answer = [];
  data.Items.forEach(item => {
    let obj = {};
    Object.keys(item).map(key => {
      switch(key){
        case "areaconst" : obj[key] = parseInt(item[key].N, 10); break;
        case "lat" : obj[key] = parseInt(item[key].N, 10); break;
        case "lon" : obj[key] = parseInt(item[key].N, 10); break;
        case "visita" : obj[key] = item[key].BOOL; break;
        default : obj[key] = item[key].S;
      }
    });
    answer.push(obj);
  });
  return answer;
}