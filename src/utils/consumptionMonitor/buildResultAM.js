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

  resultObject.image1 = "/money_energy.png";

  resultObject.image2 = "/plug_energy.png";

  resultObject.image3 = "/alert_icon.png";

  return resultObject;

}