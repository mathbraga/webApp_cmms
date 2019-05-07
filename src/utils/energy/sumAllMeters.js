export default function sumAllMeters(data, meterType) {
  // Input:
  // data (array): array (length = number of meters) with data retrieved from query
  //
  // Output:
  // newData (array): array (length = 1) with sum data of all meters summed up
  //
  // Purpose:
  // Provide aggregate data, to be shown in results components, in the same format (data.Items) as a query response for a single meter
  
  // Number of meters to loop through queryResponse
  var numMeters = data.length;

  // Initializes newData array, considering all attributes in EnergyTable
  var newData = [];
  switch(meterType){
    case("1") : newData = [
      {
        Items: [
          {
            basec: 0,
            cip: 0,
            dcf: 0,
            dcp: 0,
            desc: 0,
            dff: 0,
            dfp: 0,
            dmf: 0,
            dmp: 0,
            dms: 0,
            uferf: 0,
            uferp: 0,
            icms: 0,
            jma: 0,
            kwh: 0,
            kwhf: 0,
            kwhp: 0,
            tipo: 0,
            trib: 0,
            vbru: 0,
            vdff: 0,
            vdfp: 0,
            verexf: 0,
            verexp: 0,
            vliq: 0,
            vudf: 0,
            vudp: 0
          }
        ]
      }
    ];
    break;
    case("2") : newData = [
      {
        Items: [
          {
            lat: 0,
            lan: 0,
            dif: 0,
            consm: 0,
            consf: 0,
            vagu: 0,
            vesg: 0,
            adic: 0,
            subtotal: 0,
            cofins: 0,
            irpj: 0,
            csll: 0,
            pasep: 0
          }
        ]
      }
    ];
    break;
  }
    
  // Loops through queryResponse to build newData array
  for (let j = 0; j <= numMeters - 1; j++) {
    if (data[j].Items.length > 0) {
      // If current meter does not have data, will not be considered for sum
      
      Object.keys(newData[0].Items[0]).forEach(key => {
        if(key === "dms"){
          newData[0].Items[0][key] = newData[0].Items[0][key] +
            (data[j].Items[0].dmp > data[j].Items[0].dmf
              ? data[j].Items[0].dmp
              : data[j].Items[0].dmf);
        } else {
          newData[0].Items[0][key] = newData[0].Items[0][key] + data[j].Items[0][key]
        }
      });
      
      
      // newData[0].Items[0].basec =
      //   newData[0].Items[0].basec + data[j].Items[0].basec;
      // newData[0].Items[0].cip = newData[0].Items[0].cip + data[j].Items[0].cip;
      // newData[0].Items[0].dcf = newData[0].Items[0].dcf + data[j].Items[0].dcf;
      // newData[0].Items[0].dcp = newData[0].Items[0].dcp + data[j].Items[0].dcp;
      // newData[0].Items[0].desc =
      //   newData[0].Items[0].desc + data[j].Items[0].desc;
      // newData[0].Items[0].dff = newData[0].Items[0].dff + data[j].Items[0].dff;
      // newData[0].Items[0].dfp = newData[0].Items[0].dfp + data[j].Items[0].dfp;
      // newData[0].Items[0].dmf = newData[0].Items[0].dmf + data[j].Items[0].dmf;
      // newData[0].Items[0].dmp = newData[0].Items[0].dmp + data[j].Items[0].dmp;
      // newData[0].Items[0].dms =
      //   newData[0].Items[0].dms +
      //   (data[j].Items[0].dmp > data[j].Items[0].dmf
      //     ? data[j].Items[0].dmp
      //     : data[j].Items[0].dmf);
      // newData[0].Items[0].uferf =
      //   newData[0].Items[0].uferf + data[j].Items[0].uferf;
      // newData[0].Items[0].uferp =
      //   newData[0].Items[0].uferp + data[j].Items[0].uferp;
      // newData[0].Items[0].icms =
      //   newData[0].Items[0].icms + data[j].Items[0].icms;
      // newData[0].Items[0].jma = newData[0].Items[0].jma + data[j].Items[0].jma;
      // newData[0].Items[0].kwh = newData[0].Items[0].kwh + data[j].Items[0].kwh;
      // newData[0].Items[0].kwhf =
      //   newData[0].Items[0].kwhf + data[j].Items[0].kwhf;
      // newData[0].Items[0].kwhp =
      //   newData[0].Items[0].kwhp + data[j].Items[0].kwhp;
      // newData[0].Items[0].tipo =
      //   newData[0].Items[0].tipo + data[j].Items[0].tipo;
      // newData[0].Items[0].trib =
      //   newData[0].Items[0].trib + data[j].Items[0].trib;
      // newData[0].Items[0].vbru =
      //   newData[0].Items[0].vbru + data[j].Items[0].vbru;
      // newData[0].Items[0].vdff =
      //   newData[0].Items[0].vdff + data[j].Items[0].vdff;
      // newData[0].Items[0].vdfp =
      //   newData[0].Items[0].vdfp + data[j].Items[0].vdfp;
      // newData[0].Items[0].verexf =
      //   newData[0].Items[0].verexf + data[j].Items[0].verexf;
      // newData[0].Items[0].verexp =
      //   newData[0].Items[0].verexp + data[j].Items[0].verexp;
      // newData[0].Items[0].vliq =
      //   newData[0].Items[0].vliq + data[j].Items[0].vliq;
      // newData[0].Items[0].vudf =
      //   newData[0].Items[0].vudf + data[j].Items[0].vudf;
      // newData[0].Items[0].vudp =
      //   newData[0].Items[0].vudp + data[j].Items[0].vudp;
    }
  }
  return newData;
}
