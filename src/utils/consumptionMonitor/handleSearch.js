import checkSearchInputs from "./checkSearchInputs";
import queryTable from "./queryTable";
import defineNewLocation from "./defineNewLocation";
import aammTransformDate from "./aammTransformDate";
import sumAllMeters from "./sumAllMeters";
import removeEmptyMeters from "./removeEmptyMeters";
import makeChartConfigs from "./makeChartConfigs";
import buildResultOM from "./buildResultOM";
import buildResultOP from "./buildResultOP";
import buildResultAP from "./buildResultAP";
import buildResultAM from "./buildResultAM";

export default function handleSearch(initialDate, finalDate, oneMonth, chosenMeter, meterType, meters, dbObject, tableName) {
  return new Promise((resolve, reject) => {
    // Check date inputs
    if (
      checkSearchInputs(
        initialDate,
        finalDate,
        oneMonth
      )
    ) {
      // Run code below in case of correct search parameters inputs (checkSearchInputs returns true)

      // Transform dates inputs (from 'mm/yyyy' format to 'yymm' format)
      var aamm1 = aammTransformDate(initialDate);
      var aamm2 = "";
      if (oneMonth) {
        aamm2 = aamm1;
      } else {
        aamm2 = aammTransformDate(finalDate);
      }

      // Define new location
      var newLocation = defineNewLocation(
        oneMonth,
        chosenMeter,
        initialDate,
        finalDate,
        meterType
      );

      // Query table
      queryTable(
        dbObject,
        tableName,
        chosenMeter,
        meters,
        aamm1,
        aamm2
      ).then(data => {
        var queryResponse = [];
        var queryResponseAll = [];
        var chartConfigs = {};
        var nonEmptyMeters = [];
        var newState = {};
        // AM case
        if (chosenMeter === meterType + "99" && oneMonth) {
          nonEmptyMeters = removeEmptyMeters(data);
          queryResponseAll = data;
          queryResponse = sumAllMeters(data, meterType);
          newState = {
            nonEmptyMeters: nonEmptyMeters,
            queryResponseAll: queryResponseAll,
            queryResponse: queryResponse,
            showResult: true,
            error: false,
            newLocation: newLocation,
            resultObject: buildResultAM(meterType, meters, chosenMeter, queryResponse, chartConfigs, queryResponseAll, initialDate, finalDate, nonEmptyMeters)
          };
        }

        // AP case
        if (chosenMeter === meterType + "99" && !oneMonth) {
          queryResponseAll = data;
          nonEmptyMeters = removeEmptyMeters(data);
          queryResponse = data;
          chartConfigs = makeChartConfigs(queryResponse, aamm1, aamm2, meterType);
          newState = {
            nonEmptyMeters: nonEmptyMeters,
            queryResponseAll: queryResponseAll,
            queryResponse: queryResponse,
            chartConfigs: chartConfigs,
            showResult: true,
            error: false,
            newLocation: newLocation,
            resultObject: buildResultAP(meterType, meters, chosenMeter, queryResponse, chartConfigs, nonEmptyMeters, initialDate, finalDate)
          };
        }

        // OM case
        if (chosenMeter !== meterType + "99" && oneMonth) {
          queryResponse = data;
          if(queryResponse[0].Items.length === 0){
            alert("NÃO HÁ DADOS PARA O MEDIDOR NO PERÍODO PESQUISADO.\n\nPor favor, escolha novos parâmetros de pesquisa");
          } else {
            newState = {
              queryResponse: queryResponse,
              showResult: true,
              error: false,
              newLocation: newLocation,
              resultObject: buildResultOM(meterType, meters, chosenMeter, queryResponse, queryResponseAll, initialDate, finalDate)
            };
          }
        }

        // OP case
        if (chosenMeter !== meterType + "99" && !oneMonth) {
          queryResponse = data;
          chartConfigs = makeChartConfigs(queryResponse, aamm1, aamm2, meterType);
          newState = {
            queryResponse: queryResponse,
            showResult: true,
            error: false,
            newLocation: newLocation,
            chartConfigs: chartConfigs,
            resultObject: buildResultOP(meterType, meters, chosenMeter, queryResponse, initialDate, finalDate)
          };
        }
      resolve(newState);
      });

    // Browser display an alert message in case of wrong search inputs
    } else {
      reject();
    }
  });
}
