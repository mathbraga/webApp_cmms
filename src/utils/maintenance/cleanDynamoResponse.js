export default function cleanDynamoResponse(data){

  // GET ITEM CASE

  if(data.Items === undefined){

    let cleanObj = {};

    Object.keys(data.Item).map(key => {
      switch(key){
  
        case "id" : {
          if(data.Item[key].N === undefined){
            cleanObj[key] = data.Item[key].S;
          } else {
            cleanObj[key] = Number(data.Item[key].N);
          }
          break;
        }
        
        case "impact" : cleanObj[key] = data.Item[key].BOOL; break;
        case "visita" : cleanObj[key] = data.Item[key].BOOL; break;
        case "areaconst" : cleanObj[key] = Number(data.Item[key].N); break;
        case "lat" : cleanObj[key] = Number(data.Item[key].N); break;
        case "lon" : cleanObj[key] = Number(data.Item[key].N); break;
  
        default : cleanObj[key] = data.Item[key].S;
      }
    });
    return cleanObj;

    // SCAN OR QUERY CASE

  } else {

    let cleanArr = [];

    data.Items.forEach(item => {

      let obj = {};
      Object.keys(item).map(key => {
        switch(key){
  
          case "id" : {
            if(item[key].N === undefined){
              obj[key] = item[key].S;
            } else {
              obj[key] = Number(item[key].N);
            }
            break;
          }
          
          case "impact" : obj[key] = item[key].BOOL; break;
          case "visita" : obj[key] = item[key].BOOL; break;
          case "areaconst" : obj[key] = Number(item[key].N); break;
          case "lat" : obj[key] = Number(item[key].N); break;
          case "lon" : obj[key] = Number(item[key].N); break;
    
          default : obj[key] = item[key].S;
        }
      });
    cleanArr.push(obj);
  });
  return cleanArr;
  }
}