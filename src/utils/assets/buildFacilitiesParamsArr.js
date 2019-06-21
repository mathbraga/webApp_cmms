import { i } from "./facilitiesData";

export default function buildFacilitiesParamsArr(arr, tableName){
  
  console.clear();

  // Discard header
  let numColumns = 7;
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

  lines.forEach(facility => {

    attributesArr.push({
      PutRequest: {
        Item: {
          "idlocal": {
            S: facility[i.idlocal]
          },
          "edificio": {
            S: facility[i.edificio]
          },
          "pavimento": {
            S: facility[i.pavimento]
          },
          "visita": {
            BOOL: facility[i.visita] === "true"
          },
          "latitude": {
            N: facility[i.latitude]
          },
          "longitude": {
            N: facility[i.longitude]
          },
          "areaconst": {
            N: facility[i.areaconst]
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