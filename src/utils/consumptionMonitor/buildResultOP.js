import transformDateString from "./transformDateString";
import dateWithFourDigits from "./dateWithFourDigits";
import formatNumber from "./formatText";
import applyFuncToAttr from "./objectOperations";
import ReportInfo from "../../components/Reports/ReportInfo";

export default function buildResultOP(meterType, meters, chosenMeter, queryResponse){

  let resultObject = {};

  const { Items } = queryResponse[0];

  resultObject.totalKWh = applyFuncToAttr(Items, "kwh", (...values) =>
    values.reduce((previous, current) => (current += previous))
  );

  resultObject.totalVbru = applyFuncToAttr(Items, "vbru", (...values) =>
    values.reduce((previous, current) => (current += previous))
  );

  resultObject.demMax = Math.max(
    applyFuncToAttr(Items, "dmf", Math.max),
    applyFuncToAttr(Items, "dmp", Math.max)
  );

  resultObject.demMinFP = applyFuncToAttr(Items, "dmf", Math.min);

  resultObject.demMinP = applyFuncToAttr(Items, "dmp", Math.min);

  resultObject.demMin = 0;

  if (resultObject.demMinFP === 0) {
    resultObject.demMin = resultObject.demMinP;
  } else if (resultObject.demMinP === 0) {
    resultObject.demMin = resultObject.demMinFP;
  } else resultObject.demMin = Math.min(resultObject.demMinFP, resultObject.demMinP);

  resultObject.consMax = applyFuncToAttr(Items, "kwh", Math.max);

  resultObject.consMin = applyFuncToAttr(Items, "kwh", Math.min);

  resultObject.erexSum = applyFuncToAttr(Items, "verexf", (...values) =>
    values.reduce((previous, current) => (current += previous))
  );

  resultObject.erexSum += applyFuncToAttr(Items, "verexp", (...values) =>
    values.reduce((previous, current) => (current += previous))
  );

  resultObject.multaSum = applyFuncToAttr(Items, "jma", (...values) =>
    values.reduce((previous, current) => (current += previous))
  );

  resultObject.lastType = false;
  Items.forEach(item => {
    let lastDate = false;
    if (lastDate || item.aamm > lastDate) {
      lastDate = item.aamm;
      resultObject.lastType = item.tipo;
    }
  });

  meters.forEach(meter => {
    if((parseInt(meter.med.N) + 100*parseInt(meter.tipomed.N)) === parseInt(chosenMeter)){
      resultObject.unit = meter;
    }
  });

  resultObject.queryResponse = queryResponse[0].Items;

  resultObject.dateString = transformDateString(applyFuncToAttr(resultObject.queryResponse, "aamm", Math.max));

  resultObject.image1 = "/money_energy.png";

  resultObject.image2 = "/plug_energy.png";

  resultObject.image3 = "/alert_icon.png";

  resultObject.typeText = {
    0: "Convencional",
    1: "Horária - Verde",
    2: "Horária - Azul"
  };

  resultObject.itemsForChart = [
    "vbru",
    "vliq",
    "cip",
    "desc",
    "jma",
    "kwh",
    "confat",
    "kwhf",
    "kwhp",
    "dms",
    "dmf",
    "dmp",
    "dcf",
    "dcp",
    "dff",
    "dfp",
    "vdff",
    "vdfp",
    "vudf",
    "vudp",
    "tipo",
    "verexf",
    "verexp",
    "uferf",
    "uferp",
    "trib",
    "icms",
    "basec"
  ];

  resultObject.rowNamesInfo = [
    { name: "Identificação CEB", attr: "id" },
    { name: "Nome do medidor", attr: "nome" },
    { name: "Contrato", attr: "ct" },
    { name: "Classe", attr: "classe" },
    { name: "Subclasse", attr: "subclasse" },
    { name: "Grupo", attr: "grupo" },
    { name: "Subgrupo", attr: "subgrupo" },
    { name: "Ligação", attr: "lig" },
    { name: "Modalidade tarifária", attr: "modtar" },
    { name: "Locais", attr: "locais" },
    { name: "Demanda contratada (FP/P)", attr: "dem" },
    { name: "Observações", attr: "obs" }
  ];

  resultObject.rowNamesReportProblems = false;

  resultObject.problems = false;

  resultObject.numProblems = false;

  return resultObject;

}