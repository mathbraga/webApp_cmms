export function checkProblems(unitBill) {
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

  const result = {
    erex: { problem: false, value: unitBill.verexp + unitBill.verexf },
    ultrap: { problem: false, value: unitBill.vudp + unitBill.vudf },
    multa: { problem: false, value: unitBill.jma },
    compensacao: { problem: false, value: unitBill.desc },
    dtipo: { problem: false, value: unitBill.tipo },

    dmedidaP: { problem: false, value: unitBill.dmp },
    dmedidaFP: { problem: false, value: unitBill.dmf },

    dcontratadaP: { problem: false, value: unitBill.dcp },
    dcontratadaFP: { problem: false, value: unitBill.dcf },

    dfaturadaP: { problem: false, value: unitBill.dfp, expected: 0 },
    dfaturadaFP: { problem: false, value: unitBill.dff, expected: 0 }
  };

  // Check "EREX"
  if (unitBill.verexf !== 0 || unitBill.verexp !== 0) {
    result.erex.problem = true;
  }

  // Check "ultrapassagem"
  if (unitBill.vudf !== 0 || unitBill.vudp !== 0) {
    result.ultrap.problem = true;
  }

  // Check "multa"
  if (unitBill.jma !== 0) {
    result.multa.problem = true;
  }

  // Check "compensação"
  if (unitBill.desc !== 0) {
    result.compensacao.problem = true;
  }

  // Check "Demanda contrada, medida e faturada"
  switch (unitBill.tipo) {
    // Case type is "Verde"
    case 1:
      // "Contrada"
      if (unitBill.dc === 0) {
        result.dcontratadaFP.problem = true;
      }
      // "Medida"
      if (unitBill.dmf === 0) {
        result.dmedidaFP.problem = true;
      }
      // Check "demanda faturada"
      if (unitBill.dmf < unitBill.dc) {
        if (unitBill.dff !== unitBill.dc) {
          result.dfaturadaFP.problem = true;
        }
      } else {
        if (unitBill.dff !== unitBill.dmf) {
          result.dfaturadaFP.problem = true;
          result.dfaturadaFP.expected = unitBill.dmf;
        }
      }
      break;

    // Case type is "Azul"
    case 2:
      // Contratada
      if (unitBill.dcp === 0) {
        result.dcontratadaP.problem = true;
      }
      if (unitBill.dcf === 0) {
        result.dcontratadaFP.problem = true;
      }
      // Medida
      if (unitBill.dmp === 0) {
        result.dmedidaP.problem = true;
      }
      if (unitBill.dmf === 0) {
        result.dmedidaFP.problem = true;
      }
      // Check "demanda faturada"
      if (unitBill.dmp < unitBill.dcp) {
        if (unitBill.dfp !== unitBill.dcp) {
          result.dfaturadaP.problem = true;
          result.dfaturadaP.expected = unitBill.dcp;
        }
      } else {
        if (unitBill.dfp !== unitBill.dmp) {
          result.dfaturadaP.problem = true;
          result.dfaturadaP.expected = unitBill.dmp;
        }
      }
      if (unitBill.dmf < unitBill.dcf) {
        if (unitBill.dff !== unitBill.dcf) {
          result.dfaturadaFP.problem = true;
          result.dfaturadaFP.expected = unitBill.dcf;
        }
      } else {
        if (unitBill.dff !== unitBill.dmf) {
          result.dfaturadaFP.problem = true;
          result.dfaturadaFP.expected = unitBill.dmf;
        }
      }
      break;
    default:
      break;
  }

  return result;
}
