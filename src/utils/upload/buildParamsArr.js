export default function buildParamsArr(arr, tableName){
  
  /////////////////////////////////////////////
  tableName = tableName + "teste"; // REMOVE THIS LINE AFTER TESTS
  //////////////////////////////////////////////

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

  let noHeaderNumbers = [];
  lines.forEach((line, index) => {
    noHeaderNumbers.push([]);
    line.forEach(element => {
      noHeaderNumbers[index].push(Number(element));
    });
  });

  console.log("noHeaderNumbers:");
  console.log(noHeaderNumbers);

  let attributes = [];

  noHeaderNumbers.forEach(meter => {
    let med = 0;
    switch(meter[0]){
      case 466453: med = 101;break;
      case 471550: med = 102;break;
      case 471551: med = 103;break;
      case 471552: med = 104;break;
      case 471553: med = 105;break;
      case 471554: med = 106;break;
      case 471555: med = 107;break;
      case 472913: med = 108;break;
      case 491042: med = 109;break;
      case 491747: med = 110;break;
      case 491750: med = 111;break;
      case 493169: med = 112;break;
      case 510213: med = 113;break;
      case 605120: med = 114;break;
      case 623849: med = 115;break;
      case 675051: med = 116;break;
      case 856960: med = 117;break;
      case 856967: med = 118;break;
      case 856969: med = 119;break;
      case 966027: med = 120;break;
      case 1089425: med = 121;break;
      case 1100496: med = 122;break;
      case 1951042: med = 123;break;
      default: med = 100;
    }
    let aamm = meter[12];
    let tipo = 0;
    if(meter[56] !== 0){
      tipo = 2;
    } else {
      if(meter[58] !== 0){
        tipo = 1;
      }
    }
    let datav = meter[19];
    let kwh = 0;
    if(tipo === 0){
      kwh = meter[39];
    } else {
      kwh = meter[20];
    }
    let confat = 0;
    if(tipo === 0){
      confat = meter[40];
    }
    let icms = meter[21];
    let cip = meter[23];
    let trib = meter[24] + meter[25] + meter[26] + meter[27];
    let jma = meter[28] + meter[29];
    let desc = meter[30];
    let basec = meter[31];
    let vliq = meter[37];
    let vbru = meter[38];
    let kwhp = meter[53];
    let kwhf = 0;
    if(tipo === 0){
      kwhf = meter[39];
    } else {
      kwhf = meter[54];
    }
    let dmp = meter[56];
    let dmf = meter[57];
    let dfp = meter[59];
    let dff = 0;
    if(meter[60] !== 0){
      dff = meter[60];
    } else {
      dff = meter[58];
    }
    let uferp = meter[62];
    let uferf = meter[63];
    let verexp = meter[68]/(1 - meter[22]/100);
    let verexf = meter[69]/(1 - meter[22]/100);
    let vdfp = meter[76]/(1 - meter[22]/100);
    let vdff = 0;
    if(tipo === 1){
      vdff = meter[75]/(1 - meter[22]/100);
    }
    if(tipo === 2){
      vdff = meter[77]/(1 - meter[22]/100);
    }
    let vudp = meter[79]/(1 - meter[22]/100);
    let vudf = 0;
    if(tipo === 1){
      vudf = meter[78]/(1 - meter[22]/100);
    }
    if(tipo === 2){
      vudf = meter[80]/(1 - meter[22]/100);
    }
    let dcp = 0;
    if(tipo === 2){
      dcp = meter[82];
    }
    let dcf = 0;
    if(tipo === 1){
      dcf = meter[81];
    }
    if(tipo === 2){
      dcf = meter[83];
    }
    attributes.push({
      PutRequest: {
        Item: {
          "med": {
            N: med.toString()
          },
          "aamm": {
            N: aamm.toString().slice(2)
          },
          "tipo": {
            N: tipo.toString()
          },
          "datav": {
            N: datav.toString()
          },
          "kwh": {
            N: kwh.toString()
          },
          "confat": {
            N: confat.toString()
          },
          "icms": {
            N: icms.toString()
          },
          "cip": {
            N: cip.toString()
          },
          "trib": {
            N: trib.toString()
          },
          "jma": {
            N: jma.toString()
          },
          "desc": {
            N: desc.toString()
          },
          "basec": {
            N: basec.toString()
          },
          "vliq": {
            N: vliq.toString()
          },
          "vbru": {
            N: vbru.toString()
          },
          "kwhp": {
            N: kwhp.toString()
          },
          "kwhf": {
            N: kwhf.toString()
          },
          "dmp": {
            N: dmp.toString()
          },
          "dmf": {
            N: dmf.toString()
          },
          "dfp": {
            N: dfp.toString()
          },
          "dff": {
            N: dff.toString()
          },
          "uferp": {
            N: uferp.toString()
          },
          "uferf": {
            N: uferf.toString()
          },
          "verexp": {
            N: verexp.toString()
          },
          "verexf": {
            N: verexf.toString()
          },
          "vdfp": {
            N: vdfp.toString()
          },
          "vdff": {
            N: vdff.toString()
          },
          "vudp": {
            N: vudp.toString()
          },
          "vudf": {
            N: vudf.toString()
          },
          "dcp": {
            N: dcp.toString()
          },
          "dcf": {
            N: dcf.toString()
          }
        }
      }
    });
  });

  console.log("attributes:");
  console.log(attributes);

  let maxLength = 25;
  let paramsArr = [];
  while(attributes.length > 0){
    paramsArr.push({RequestItems: {[tableName]: attributes.splice(0, maxLength)}})
  }
  return paramsArr;
}