export default function cleanDynamoGetItemResponse(data){
  let obj = {}
  Object.keys(data.Item).map(key => {
    switch(key){
      case "id" : obj[key] = data.Item[key].N; break;
      case "impact" : obj[key] = data.Item[key].BOOL; break;
      default : obj[key] = data.Item[key].S;
    }
  });
  return obj;
}