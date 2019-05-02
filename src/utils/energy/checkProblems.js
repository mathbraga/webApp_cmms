export default function checkProblems(unitBill, chosenMeter, queryResponseAll) {
  // Input: object (unitBill). Obj: {aamm, basec, cip, datav, dc, dcf, dcp, desc, dff, dfp ,dmf, dmp,
  //                                      erexf, erexp, icms, jma, kwh, kwhf, kwhp, med, tipo, trib, vbru, vdff, bdfp,
  //                                      verexf, verexp, vliq, vudf, vudp}
  // Output: object with the problems. Obj: {erex, ultrap, multa, compensacao, dmedida, dcontratada, dfaturada}
  //          erex: {prob, valuep, valuefp}, .....
  // Purpose: Check the following problems. Case of problems:
  //              - The values for "erex, ultrapassagem, multa, compensação" are not 0;
  //              - If "tipo" is 2 and "demanda contratada, demanda medida (ponta e fora)" are 0;
  //              - If "tipo" is 1 and "demanda contrada, demanda medida (fora)" are 0;
  //              - Check "demanda faturada".

  let result = {};
  if(chosenMeter === "199"){
    result = {
      dcp: { problem: false, value: unitBill.dcp, meters: [] },
      dcf: { problem: false, value: unitBill.dcf, meters: [] },
      dmp: { problem: false, value: unitBill.dmp, meters: [] },
      dmf: { problem: false, value: unitBill.dmf, meters: [] },
      dfp: { problem: false, value: unitBill.dfp, expected: 0, meters: [] },
      dff: { problem: false, value: unitBill.dff, expected: 0, meters: [] },
      vudp: { problem: false, value: unitBill.vudp, meters: [] },
      vudf: { problem: false, value: unitBill.vudf, meters: [] },
      verexp: { problem: false, value: unitBill.verexp, meters: [] },
      verexf: { problem: false, value: unitBill.verexf, meters: [] },
      jma: { problem: false, value: unitBill.jma, meters: [] },
      desc: { problem: false, value: unitBill.desc, meters: [] },
      tipo: { problem: false, value: unitBill.tipo, meters: [] }
    };
  } else {
    result = {
      dcp: { problem: false, value: unitBill.dcp },
      dcf: { problem: false, value: unitBill.dcf },
      dmp: { problem: false, value: unitBill.dmp },
      dmf: { problem: false, value: unitBill.dmf },
      dfp: { problem: false, value: unitBill.dfp, expected: 0 },
      dff: { problem: false, value: unitBill.dff, expected: 0 },
      vudp: { problem: false, value: unitBill.vudp },
      vudf: { problem: false, value: unitBill.vudf },
      verexp: { problem: false, value: unitBill.verexp },
      verexf: { problem: false, value: unitBill.verexf },
      jma: { problem: false, value: unitBill.jma },
      desc: { problem: false, value: unitBill.desc },
      tipo: { problem: false, value: unitBill.tipo }
    };
  }


  if(chosenMeter === "199"){
    // Check "EREX"
    if (unitBill.verexf !== 0) {
      result.verexf.problem = true;
      queryResponseAll.forEach(element => {
        if(element.Items.length > 0){
          if(element.Items[0].verexf > 0){
            result.verexf.meters.push(element.Items[0].med);
          }
        }
      });
    }

    if (unitBill.verexp !== 0) {
      result.verexp.problem = true;
      queryResponseAll.forEach(element => {
        if(element.Items.length > 0){
          if(element.Items[0].verexp > 0){
            result.verexp.meters.push(element.Items[0].med);
          }
        }
      });
    }

    // Check "ultrapassagem"
    if (unitBill.vudf !== 0){
      result.vudf.problem = true;
      queryResponseAll.forEach(element => {
        if(element.Items.length > 0){
          if(element.Items[0].vudf > 0){
            result.vudf.meters.push(element.Items[0].med);
          }
        }
      });
    }

    if (unitBill.vudp !== 0) {
      result.vudp.problem = true;
      queryResponseAll.forEach(element => {
        if(element.Items.length > 0){
          if(element.Items[0].vudp > 0){
            result.vudp.meters.push(element.Items[0].med);
          }
        }
      });
    }

    // Check "multa"
    if (unitBill.jma !== 0) {
      result.jma.problem = true;
      queryResponseAll.forEach(element => {
        if(element.Items.length > 0){
          if(element.Items[0].jma > 0){
            result.jma.meters.push(element.Items[0].med);
          }
        }
      });
    }

    // Check "compensação"
    if (unitBill.desc !== 0) {
      result.desc.problem = true;
      queryResponseAll.forEach(element => {
        if(element.Items.length > 0){
          if(element.Items[0].desc > 0){
            result.desc.meters.push(element.Items[0].med);
          }
        }
      });
    }

    queryResponseAll.forEach(element => {
    if(element.Items.length > 0){
      // Check "Demanda contrada, medida e faturada"
      switch (element.Items[0].tipo) {
        // Case type is "Verde"
        case 1:
          // "Contrada"
          if (element.Items[0].dcf === 0) {
            result.dcf.problem = true;
            result.dcf.meters.push(element.Items[0].med);
          }
          // "Medida"
          if (element.Items[0].dmf === 0) {
            result.dmf.problem = true;
            result.dmf.meters.push(element.Items[0].med);
          }
          // Check "demanda faturada"
          if (element.Items[0].dmf < element.Items[0].dcf) {
            if (element.Items[0].dff !== element.Items[0].dcf) {
              result.dff.problem = true;
              result.dff.meters.push(element.Items[0].med);
            }
          } else {
            if (element.Items[0].dff !== element.Items[0].dmf) {
              result.dff.problem = true;
              result.dff.expected = element.Items[0].dmf;
              result.dff.meters.push(element.Items[0].med);
            }
          }
          break;

        // Case type is "Azul"
        case 2:
          // Contratada
          if (element.Items[0].dcp === 0) {
            result.dcp.problem = true;
            result.dcp.meters.push(element.Items[0].med);
          }
          if (element.Items[0].dcf === 0) {
            result.dcf.problem = true;
            result.dcf.meters.push(element.Items[0].med);
          }
          // Medida
          if (element.Items[0].dmp === 0) {
            result.dmp.problem = true;
            result.dmp.meters.push(element.Items[0].med);
          }
          if (element.Items[0].dmf === 0) {
            result.dmf.problem = true;
            result.dmf.meters.push(element.Items[0].med);
          }
          // Check "demanda faturada"
          if (element.Items[0].dmp < element.Items[0].dcp) {
            if (element.Items[0].dfp !== element.Items[0].dcp) {
              result.dfp.problem = true;
              result.dfp.expected = element.Items[0].dcp;
              result.dfp.meters.push(element.Items[0].med);
            }
          } else {
            if (element.Items[0].dfp !== element.Items[0].dmp) {
              result.dfp.problem = true;
              result.dfp.expected = element.Items[0].dmp;
              result.dmp.meters.push(element.Items[0].med);
            }
          }
          if (element.Items[0].dmf < element.Items[0].dcf) {
            if (element.Items[0].dff !== element.Items[0].dcf) {
              result.dff.problem = true;
              result.dff.expected = element.Items[0].dcf;
              result.dff.meters.push(element.Items[0].med);
            }
          } else {
            if (element.Items[0].dff !== element.Items[0].dmf) {
              result.dff.problem = true;
              result.dff.expected = element.Items[0].dmf;
              result.dff.meters.push(element.Items[0].med);
            }
          }
        break;
        default:
        break;
      }
    }



















    });






////////////////////////////////////////////////// CASE ONE METER ///////////////



  } else {
    if (unitBill.verexf !== 0) {
      result.verexf.problem = true;
    }

    if (unitBill.verexp !== 0) {
      result.verexp.problem = true;
    }

    // Check "ultrapassagem"
    if (unitBill.vudf !== 0){
      result.vudf.problem = true;
    }

    if (unitBill.vudp !== 0) {
      result.vudp.problem = true;
    }

    // Check "multa"
    if (unitBill.jma !== 0) {
      result.jma.problem = true;
    }

    // Check "compensação"
    if (unitBill.desc !== 0) {
      result.desc.problem = true;
    }
  
    // Check "Demanda contrada, medida e faturada"
    switch (unitBill.tipo) {
      // Case type is "Verde"
      case 1:
        // "Contrada"
        if (unitBill.dcf === 0) {
          result.dcf.problem = true;
        }
        // "Medida"
        if (unitBill.dmf === 0) {
          result.dmf.problem = true;
        }
        // Check "demanda faturada"
        if (unitBill.dmf < unitBill.dcf) {
          if (unitBill.dff !== unitBill.dcf) {
            result.dff.problem = true;
          }
        } else {
          if (unitBill.dff !== unitBill.dmf) {
            result.dff.problem = true;
            result.dff.expected = unitBill.dmf;
          }
        }
        break;

      // Case type is "Azul"
      case 2:
        // Contratada
        if (unitBill.dcp === 0) {
          result.dcp.problem = true;
        }
        if (unitBill.dcf === 0) {
          result.dcf.problem = true;
        }
        // Medida
        if (unitBill.dmp === 0) {
          result.dmp.problem = true;
        }
        if (unitBill.dmf === 0) {
          result.dmf.problem = true;
        }
        // Check "demanda faturada"
        if (unitBill.dmp < unitBill.dcp) {
          if (unitBill.dfp !== unitBill.dcp) {
            result.dfp.problem = true;
            result.dfp.expected = unitBill.dcp;
          }
        } else {
          if (unitBill.dfp !== unitBill.dmp) {
            result.dfp.problem = true;
            result.dfp.expected = unitBill.dmp;
          }
        }
        if (unitBill.dmf < unitBill.dcf) {
          if (unitBill.dff !== unitBill.dcf) {
            result.dff.problem = true;
            result.dff.expected = unitBill.dcf;
          }
        } else {
          if (unitBill.dff !== unitBill.dmf) {
            result.dff.problem = true;
            result.dff.expected = unitBill.dmf;
          }
        }
      break;
      default:
      break;
    }
  }
  return result;
}
