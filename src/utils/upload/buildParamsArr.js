export default function buildParamsArr(arr, tableName){
  
  /////////////////////////////////////////////////
  tableName = tableName + "teste"; // REMOVE AFTER TESTING IS OK
  /////////////////////////////////////////////////

  // Discard header
  let numColumns = 102;
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

  console.log("lines:");
  console.log(lines);

  // Build array of requests for each line (meter) using AWS DynamoDB JSON format
  let requestItemsArr = [];
  lines.forEach(line => {
    requestItemsArr.push({
      PutRequest: {
        Item: {
          "med": {
            N: line[0]
          },
          "aamm": {
            N: line[12].slice(2)
          },
          "kwh": {
            N: line[1]
          }
        }
      }
    });
  });
  console.log("requestItemsArr:");
  console.log(requestItemsArr);

  // Build paramsArr. Each element is an array with maximum length = 25 (AWS limit for batchWriteTtem API)
  let maxLength = 25;
  let paramsArr = [];
  while(requestItemsArr.length > 0){
    paramsArr.push({RequestItems: {[tableName]: requestItemsArr.splice(0, maxLength)}})
  }
  return paramsArr;
}