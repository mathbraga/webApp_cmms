export default function cleanDynamoGetItemResponse(data){
  let obj = {}
  Object.keys(data.Item).map(key => {
    switch(key){

      case "id" : {
        if(data.Item[key].N === undefined){
          obj[key] = data.Item[key].S;
        } else {
          obj[key] = Number(data.Item[key].N);
        }
        break;
      }
      
      case "impact" : obj[key] = data.Item[key].BOOL; break;
      case "visita" : obj[key] = data.Item[key].BOOL; break;
      case "areaconst" : obj[key] = Number(data.Item[key].N); break;
      case "lat" : obj[key] = Number(data.Item[key].N); break;
      case "lon" : obj[key] = Number(data.Item[key].N); break;

      default : obj[key] = data.Item[key].S;
    }
  });
  return obj;
}