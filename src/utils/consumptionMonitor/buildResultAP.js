import { transformDateString } from "./transformDateString";
import formatNumber from "./formatText";
import applyFuncToAttr from "./objectOperations";
import ReportInfo from "../../components/Reports/ReportInfo";

export default function buildResultAP(meterType, meters, chosenMeter, queryResponse, chartConfigs){

  let resultObject = {};

  resultObject.queryResponse = queryResponse[0].Items[0];

  resultObject.totalValues = {};
  Object.keys(chartConfigs).forEach(key => {
    const values = chartConfigs[key].data.datasets[0].data;
    resultObject.totalValues[key] = values.reduce(
      (previous, current) => (previous += current)
    );
  });

  resultObject.itemsForChart = [
    "vbru",
    "vliq",
    "cip",
    "desc",
    "jma",
    "kwh",
    "kwhf",
    "kwhp",
    "dms",
    "vdff",
    "vdfp",
    "vudf",
    "vudp",
    "verexf",
    "verexp",
    "uferf",
    "uferp",
    "trib",
    "icms",
    "basec"
  ];

  resultObject.demMax = Math.max(...chartConfigs.dms.data.datasets[0].data);

  resultObject.image1 = "/money_energy.png";

  resultObject.image2 = "/plug_energy.png";

  resultObject.image3 = "/alert_icon.png";

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

  return resultObject;

}