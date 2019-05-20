import transformDateString from "./transformDateString";
import formatNumber from "./formatText";
import dateWithFourDigits from "./dateWithFourDigits";

export default function buildResultAP(meterType, meters, chosenMeter, queryResponse, chartConfigs, nonEmptyMeters, initialDate, finalDate){

  let resultObject = {};

  resultObject.queryResponse = queryResponse[0].Items[0];

  resultObject.totalValues = {};
  Object.keys(chartConfigs).forEach(key => {
    const values = chartConfigs[key].data.datasets[0].data;
    resultObject.totalValues[key] = values.reduce(
      (previous, current) => (previous += current)
    );
  });

  resultObject.unitNumber = "Todos medidores";

  resultObject.allUnits = true;

  resultObject.numOfUnits = nonEmptyMeters.length;

  resultObject.unitName = resultObject.numOfUnits.toString() + " medidores";

  resultObject.typeText = false;

  resultObject.imageWidgetOneColumn = require("../../assets/icons/money_energy.png");

  resultObject.imageWidgetThreeColumns = require("../../assets/icons/plug_energy.png");

  resultObject.imageWidgetWithModal = require("../../assets/icons/alert_icon.png");;

  resultObject.widgetOneColumnFirstTitle = "Consumo";

  resultObject.widgetOneColumnFirstValue = formatNumber(resultObject.totalValues.kwh, 0) + " kWh";

  resultObject.widgetOneColumnSecondTitle = "Gasto";

  resultObject.widgetOneColumnSecondValue = "R$ " + formatNumber(resultObject.totalValues.vbru, 2);

  resultObject.widgetThreeColumnsTitles = [
    "Demanda",
    "Ultrapass.",
    "Descontos",
    "Multas",
    "EREX",
    "UFER"
  ];

  resultObject.widgetThreeColumnsValues = [
    formatNumber(resultObject.demMax, 0) + " kW",
    "R$ " + formatNumber(resultObject.totalValues.vudf + resultObject.totalValues.vudp, 2),
    "R$ " + formatNumber(resultObject.totalValues.desc, 2),
    "R$ " + formatNumber(resultObject.totalValues.jma, 2),
    "R$ " + formatNumber(resultObject.totalValues.verexf + resultObject.totalValues.verexp, 2),
    formatNumber(resultObject.totalValues.uferf + resultObject.totalValues.uferp, 0)
  ];

  resultObject.widgetWithModalTitle = "Diagnóstico";

  resultObject.widgetWithModalButtonName = "Ver relatório";

  resultObject.rowNamesReportProblems = false;

  resultObject.problems = false;

  resultObject.numProblems = false;

  resultObject.demMax = Math.max(...chartConfigs.dms.data.datasets[0].data);

  resultObject.initialDate = transformDateString(dateWithFourDigits(initialDate));
  
  resultObject.finalDate = transformDateString(dateWithFourDigits(finalDate));

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

  resultObject.chartReportTitle = "Gráfico do período";

  resultObject.chartReportTitleColSize = 3;

  resultObject.chartSubtitle = "Total: "

  resultObject.chartSubvalue = resultObject.unitName;

  return resultObject;

}