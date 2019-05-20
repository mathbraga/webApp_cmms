import { transformDateString, dateWithFourDigits } from "./transformDateString";
import formatNumber from "./formatText";
import applyFuncToAttr from "./objectOperations";
import ReportInfo from "../../components/Reports/ReportInfo";
import checkProblems from "./checkProblems";

export default function buildResultAP(meterType, meters, chosenMeter, queryResponse, chartConfigs, queryResponseAll, initialDate, finalDate){

  let resultObject = {};

  resultObject.queryResponse = queryResponse[0].Items[0];

  resultObject.totalValues = {};
  Object.keys(chartConfigs).forEach(key => {
    const values = chartConfigs[key].data.datasets[0].data;
    resultObject.totalValues[key] = values.reduce(
      (previous, current) => (previous += current)
    );
  });

  resultObject.image1 = "/money_energy.png";

  resultObject.image2 = "/plug_energy.png";

  resultObject.image3 = "/alert_icon.png";

  resultObject.problems  = checkProblems(queryResponse, chosenMeter, queryResponseAll);
  
  resultObject.numProblems = 0;
  Object.keys(resultObject.problems).forEach(key => {
    if (resultObject.problems[key].problem === true) resultObject.numProblems += 1;
  });


  resultObject.rowNamesReportProblems = {
    dcp: {
      name: "Demanda contratada - Ponta",
      unit: "kW",
      obs:
        "Maior que zero somente na modalidade tarifária horária Azul. Igual a zero nos outros casos.",
      expected: "≥ 0 kW"
    },
    dcf: {
      name: "Demanda contratada - Fora de ponta",
      unit: "kW",
      obs: "Igual a zero somente na modalidade tarirária convencional",
      expected: "≥ 0 kW"
    },
    dmp: {
      name: "Demanda medida - Ponta",
      unit: "kW",
      obs: "Maior demanda de potência ativa registrada no período - Ponta",
      expected: "≥ 0 kW"
    },
    dmf: {
      name: "Demanda medida - Fora de ponta",
      unit: "kW",
      obs:
        "Maior demanda de potência ativa registrada no período - Fora de ponta",
      expected: "≥ 0 kW"
    },
    dfp: {
      name: "Demanda faturada - Ponta",
      unit: "kW",
      obs:
        "Demanda considerada no faturamento (maior valor entre medida e contratada) - Ponta",
      expected: "≥ Demanda contratada (Ponta)"
    },
    dff: {
      name: "Demanda faturada - Fora de ponta",
      unit: "kW",
      obs:
        "Demanda considerada no faturamento (maior valor entre medida e contratada) - Fora de ponta",
      expected: "≥ Demanda contratada (Fora de ponta)"
    },

    vudp: {
      name: "Custo da ultrapassagem de demanda - Ponta",
      unit: "R$",
      obs:
        "Valor adicional em caso de demanda medida superior à demanda contratada",
      expected: "= R$ 0,00"
    },

    vudf: {
      name: "Custo da ultrapassagem de demanda - Fora de ponta",
      unit: "R$",
      obs:
        "Valor adicional em caso de demanda medida superior à demanda contratada",
      expected: "= R$ 0,00"
    },

    verexp: {
      name: "Custo do EREX - Ponta",
      unit: "R$",
      obs:
        "Valor adicional em caso de excedentes de energia reativa (fator de potência inferior a 0,92)",
      expected: "= R$ 0,00"
    },

    verexf: {
      name: "Custo do EREX - Fora de ponta",
      unit: "R$",
      obs:
        "Valor adicional em caso de excedentes de energia reativa (fator de potência inferior a 0,92)",
      expected: "= R$ 0,00"
    },

    jma: {
      name: "Multas, juros e atualização monetária",
      unit: "R$",
      obs:
        "Valores adicionais decorrentes do atraso no pagamento de faturas anteriores",
      expected: "= R$ 0,00"
    },
    desc: {
      name: "Descontos e compensações",
      unit: "R$",
      obs:
        "Total de descontos e compensações devido a baixos indicadores de qualidade do serviço, conforme normas da ANEEL, ou correções de valores cobrados indevidamente em faturas anteriores",
      expected: "= R$ 0,00"
    }
  };

  resultObject.initialDate = transformDateString(dateWithFourDigits(initialDate));
  
  resultObject.finalDate = transformDateString(dateWithFourDigits(finalDate));



  return resultObject;

}