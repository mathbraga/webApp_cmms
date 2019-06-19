import transformDateString from "./transformDateString";
import formatNumber from "./formatText";
import dateWithFourDigits from "./dateWithFourDigits";
import removeEmptyMeters from "./removeEmptyMeters";
import makeChartConfigsWater from "./makeChartConfigsWater";

export default function buildResultAPwater(data, meterType, meters, chosenMeter, initialDate, finalDate){

  let resultObject = {};

  resultObject.newLocation = {
    hash: "",
    pathname: "/agua/resultados/AP",
    search: "",
    state: {}
  };

  resultObject.queryResponseAll = data;
  
  resultObject.nonEmptyMeters = removeEmptyMeters(data);
  
  // resultObject.queryResponseRaw = data;

  resultObject.chartConfigs = makeChartConfigsWater(data, dateWithFourDigits(initialDate), dateWithFourDigits(finalDate));

  resultObject.queryResponse = data[0].Items[0];

  resultObject.totalValues = {};
  Object.keys(resultObject.chartConfigs).forEach(key => {
    const values = resultObject.chartConfigs[key].data.datasets[0].data;
    resultObject.totalValues[key] = values.reduce(
      (previous, current) => (previous += current)
    );
  });

  resultObject.unitNumber = "Todos medidores";

  resultObject.allUnits = true;

  resultObject.numOfUnits = resultObject.nonEmptyMeters.length;

  resultObject.unitName = resultObject.numOfUnits.toString() + " medidores";

  resultObject.typeText = false;

  resultObject.imageWidgetOneColumn = require("../../assets/icons/alert_icon.png");

  resultObject.imageWidgetThreeColumns = require("../../assets/icons/alert_icon.png");

  resultObject.imageWidgetWithModal = require("../../assets/icons/alert_icon.png");;

  resultObject.widgetOneColumnFirstTitle = "Consumo";

  resultObject.widgetOneColumnFirstValue = formatNumber(resultObject.totalValues.consf, 0) + " m³";

  resultObject.widgetOneColumnSecondTitle = "Gasto";

  resultObject.widgetOneColumnSecondValue = "R$ " + formatNumber(resultObject.totalValues.subtotal, 2);

  resultObject.widgetThreeColumnsTitles = [
    "Consumo médio",
    "Consumo faturado",
    "Adicional",
    "Valor água",
    "Valor esgoto",
    "Total"
  ];

  resultObject.widgetThreeColumnsValues = [
    formatNumber(resultObject.totalValues.consm, 0) + " m³",
    formatNumber(resultObject.totalValues.consf, 0) + " m³",
    "R$ " + formatNumber(resultObject.totalValues.adic, 2),
    "R$ " + formatNumber(resultObject.totalValues.vagu, 2),
    "R$ " + formatNumber(resultObject.totalValues.vesg, 2),
    "R$ " + formatNumber(resultObject.totalValues.subtotal, 2)
  ];

  // resultObject.widgetWithModalTitle = "Diagnóstico";

  // resultObject.widgetWithModalButtonName = "Ver relatório";

  // resultObject.rowNamesReportProblems = false;

  // resultObject.problems = false;

  // resultObject.numProblems = false;

  // resultObject.demMax = Math.max(...resultObject.chartConfigs.dms.data.datasets[0].data);

  resultObject.initialDate = transformDateString(dateWithFourDigits(initialDate));
  
  resultObject.finalDate = transformDateString(dateWithFourDigits(finalDate));

  resultObject.itemsForChart = [
    "dif",
    "consm",
    "consf",
    "vagu",
    "vesg",
    "adic",
    "subtotal",
    "cofins",
    "irpj",
    "csll",
    "pasep"
  ];

  resultObject.dropdownItems = {};
  
  resultObject.itemsForChart.forEach(key => {
    resultObject.dropdownItems[key] = resultObject.chartConfigs[key].options.title.text;
  });

  resultObject.chartReportTitle = "Gráfico do período";

  resultObject.chartReportTitleColSize = 3;

  resultObject.chartSubtitle = "Total: "

  resultObject.chartSubvalue = resultObject.unitName;

  resultObject.selectedDefault = "subtotal";

  return resultObject;

}