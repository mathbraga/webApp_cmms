export default function buildAssetParamsArr(arr, tableName){
  
  // Discard header
  let numColumns = 5;
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

  // let noHeaderNumbers = [];
  // lines.forEach((line, index) => {
  //   noHeaderNumbers.push([]);
  //   line.forEach(element => {
  //     noHeaderNumbers[index].push(Number(element));
  //   });
  // });

  // console.log("noHeaderNumbers:");
  // console.log(noHeaderNumbers);

  let attributesArr = [];

  lines.forEach(asset => {
    attributesArr.push({
      PutRequest: {
        Item: {
          "id": {
            S: asset[0]
          },
          "local": {
            S: asset[1]
          },
          "model": {
            S: asset[2]
          },
          "serial": {
            S: asset[3]
          },
          "status": {
            S: asset[4]
          }
        }
      }
    });
  });

  // console.log("attributesArr:");
  // console.log(attributesArr);

  let maxLength = 25;
  let paramsArr = [];
  while(attributesArr.length > 0){
    paramsArr.push({RequestItems: {[tableName]: attributesArr.splice(0, maxLength)}})
  }
  return paramsArr;
}