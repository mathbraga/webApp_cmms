import checkSearchInputs from "./checkSearchInputs";
import queryTable from "./queryTable";
import dateWithFourDigits from "./dateWithFourDigits";
import buildResultOM from "./buildResultOM";
import buildResultOP from "./buildResultOP";
import buildResultAP from "./buildResultAP";
import buildResultAM from "./buildResultAM";

export default function handleSearch(awsData, state) {
  return new Promise((resolve, reject) => {
    
    // Inputs
    let {
      meterType,
      tableName,
      dbObject,
    } = awsData;

    let {
      initialDate,
      finalDate,
      oneMonth,
      chosenMeter,
      meters,
    } = state;
    
    // Check date inputs
    let checkInputs = checkSearchInputs(initialDate, finalDate, oneMonth);

    if(checkInputs.checkBool){
      // Run code below in case of correct search parameters inputs (checkSearchInputs returns true)
      // Transform dates inputs (from 'mm/yyyy' format to 'yymm' format)
      var aammInitial = dateWithFourDigits(initialDate);
      var aammFinal = "";
      if (oneMonth) {
        aammFinal = aammInitial;
      } else {
        aammFinal = dateWithFourDigits(finalDate);
      }

      // Query table
      queryTable(
        dbObject,
        tableName,
        chosenMeter,
        meters,
        aammInitial,
        aammFinal
      ).then(data => {
        
        // AM case
        if (chosenMeter === meterType + "99" && oneMonth) {
          resolve(buildResultAM(data, meterType, meters, chosenMeter, initialDate, finalDate));
        }
        
        // AP case
        if (chosenMeter === meterType + "99" && !oneMonth) {
          resolve(buildResultAP(data, meterType, meters, chosenMeter, initialDate, finalDate));
        }
        
        // OM case
        if (chosenMeter !== meterType + "99" && oneMonth) {
          resolve(buildResultOM(data, meterType, meters, chosenMeter, initialDate, finalDate));
        }

        // OP case
        if (chosenMeter !== meterType + "99" && !oneMonth) {
          resolve(buildResultOP(data, meterType, meters, chosenMeter, initialDate, finalDate));
        }
      }).catch((queryErrorMessage) => {
        reject(queryErrorMessage);
      });

    // Browser display an alert message in case of wrong search inputs
    } else {
      reject(checkInputs.message);
    }
  });
}
