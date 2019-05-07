export default function buildCAESBParamsArr(arr, tableName){
  
  /////////////////////////////////////////////
  tableName = tableName + "teste"; // REMOVE THIS LINE AFTER TESTS
  //////////////////////////////////////////////

  // Discard header
  let numColumns = 17;
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

  lines.forEach(meter => {
    let med = meter[0];
    let aamm = meter[1];
    let lat = meter[2];
    let dlat = meter[3];
    let lan = meter[4];
    let dlan = meter[5];
    let dif = meter[6];
    let consm = meter[7];
    let consf = meter[8];
    let vagu = meter[9];
    let vesg = meter[10];
    let adic = meter[11];
    let subtotal = meter[12];
    let cofins = meter[13];
    let irpj = meter[14];
    let csll = meter[15];
    let pasep = meter[16];

    attributesArr.push({
      PutRequest: {
        Item: {
          "med": {
            N: med
          },
          "aamm": {
            N: aamm
          },
          "lat": {
            N: lat
          },
          "dlat": {
            S: dlat
          },
          "lan": {
            N: lan
          },
          "dlan": {
            S: dlan
          },
          "dif": {
            N: dif
          },
          "consm": {
            N: consm
          },
          "consf": {
            N: consf
          },
          "vagu": {
            N: vagu
          },
          "vesg": {
            N: vesg
          },
          "adic": {
            N: adic
          },
          "subtotal": {
            N: subtotal
          },
          "cofins": {
            N: cofins
          },
          "irpj": {
            N: irpj
          },
          "csll": {
            N: csll
          },
          "pasep": {
            N: pasep
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
  return paramsArr;
}