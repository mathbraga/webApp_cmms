import { indexes } from "./locaisData";

export default function buildFacilitiesParamsArr(arr, tableName){
  
  console.clear();

  // Discard header
  let numColumns = 6;
  let noHeader = arr.splice(numColumns);

  // Remove last element (empty element because the last character in CEB csv file is ;)
  noHeader.pop();
  console.log('noHeader:');
  console.log(noHeader);

  // Split big array into many arrays (each small array represents a meter in CEB csv file)
  let lines = [];
  while(noHeader.length > 0){
    lines.push(noHeader.splice(0, numColumns));
  }

  let attributesArr = [];

  lines.forEach(local => {

    attributesArr.push({
      PutRequest: {
        Item: {
          "idlocal": {
            S: local[indexes.idlocal]
          },
          "edificio": {
            S: local[indexes.edificio]
          },
          "pavimento": {
            S: local[indexes.pavimento]
          },
          "visita": {
            S: local[indexes.visita]
          },
          "latitude": {
            S: local[indexes.latitude]
          },
          "longitude": {
            S: local[indexes.longitude]
          }
        }
      }
    });
  });

  console.log("attributesArr:");
  console.log(attributesArr);

  let maxLength = 25;
  let paramsArr = [];
  while(attributesArr.length > 0){
    paramsArr.push({RequestItems: {[tableName]: attributesArr.splice(0, maxLength)}})
  }

  console.log("paramsArr:");
  console.log(paramsArr);

  return paramsArr;
}