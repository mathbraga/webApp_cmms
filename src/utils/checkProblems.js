export function checkProblems(unitBill) {
  // Input: object (unitBill). Obj: {aamm, basec, cip, datav, dc, dcf, dcp, desc, dff, dfp ,dmf, dmp,
  //                                      erexf, erexp, icms, jma, kwh, kwhf, kwhp, med, tipo, trib, vbru, vdff, bdfp,
  //                                      verexf, verexp, vliq, vudf, vudp}
  // Output: object with the problems. Obj: {erex, ultrap, multa, comp, dmedida, dcontratada, dfaturada}
  //          erex: {prob, valuep, valuefp}, .....
  // Purpose: Check the following problems. Case of problems:
  //              - The values for "erex, ultrapassagem, multa, compensação" are not 0;
  //              - If "tipo" is 2 and "demanda contratada, demanda medida (ponta e fora)" are 0;
  //              - If "tipo" is 1 and "demanda contrada, demanda medida (fora)" are 0;
  //              - Check "demanda faturada".

  const result = {
    erex: { problem: false, valueP: 0, valueFP: 0 },
    ultrap: { problem: false, valueP: 0, valueFP: 0 },
    multa: { problem: false, value: 0 },
    comp: { problem: false, value: 0 },
    dmedida: { problem: false, tipo: 0, demP: 0, demFP: 0 },
    dcontratada: { problem: false, tipo: 0, demP: 0, demFP: 0 },
    dfaturada: {
      problem: false,
      tipo: 0,
      demP: 0,
      demFP: 0,
      realP: 0,
      realFP: 0
    }
  };

  // Check "EREX"
  if (unitBill.verexf !== 0) {
    result.erex.problem = true;
    result.erex.valueFP = unitBill.verexf;
  }
  if (unitBill.verexp !== 0) {
    result.erex.problem = true;
    result.erex.valueP = unitBill.verexp;
  }

  // Check "ultrapassagem"
  if (unitBill.vudf !== 0) {
    result.ultrap.problem = true;
    result.ultrap.valueFP = unitBill.vudf;
  }
  if (unitBill.vudp !== 0) {
    result.ultrap.problem = true;
    result.ultrap.valueP = unitBill.vudp;
  }

  // Check "multa"
  if (unitBill.jma !== 0) {
    result.multa.problem = true;
    result.multa.value = unitBill.jma;
  }

  // Check "multa"
  if (unitBill.desc !== 0) {
    result.comp.problem = true;
    result.comp.value = unitBill.desc;
  }

  // Check "Demanda contrada e medida"
  switch (unitBill.tipo) {
    // Case type is "Verde"
    case 1:
      // "Contrada"
      if (unitBill.dc === 0) {
        result.dcontratada.problem = true;
        result.dcontratada.tipo = unitBill.tipo;
        result.dcontratada.demFP = unitBill.dc;
      }
      // "Medida"
      if (unitBill.dmf === 0) {
        result.dmedida.problem = true;
        result.dmedida.tipo = unitBill.tipo;
        result.dmedida.demFP = unitBill.dc;
      }
      break;
    // Case type is "Azul"
    case 2:
      // Contratada
      if (unitBill.dcp === 0) {
        result.dcontratada.problem = true;
        result.dcontratada.tipo = unitBill.tipo;
        result.dcontratada.demP = unitBill.dcp;
      }
      if (unitBill.dcf === 0) {
        result.dcontratada.problem = true;
        result.dcontratada.tipo = unitBill.tipo;
        result.dcontratada.demFP = unitBill.dcf;
      }
      // Medida
      if (unitBill.dmp === 0) {
        result.dmedida.problem = true;
        result.dmedida.tipo = unitBill.tipo;
        result.dmedida.demP = unitBill.dmp;
      }
      if (unitBill.dmf === 0) {
        result.dmedida.problem = true;
        result.dmedida.tipo = unitBill.tipo;
        result.dmedida.demFP = unitBill.dmf;
      }
      break;
    default:
      break;
  }

  // Check "demanda faturada"

  return result;
}
