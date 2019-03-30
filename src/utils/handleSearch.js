import checkSearchInputs from "./checkSearchInputs";
import queryEnergyTable from "./queryEnergyTable";
import buildChartData from "./buildChartData";
import defineRoute from "./defineRoute";
import aammTransformDate from "./aammTransformDate";

export default function handleSearch(){

  // Check dates inputs
  if(checkSearchInputs(this.state.initialDate, this.state.finalDate, this.state.oneMonth)){
    
  // Run functions below in case of correct search parameters inputs (checkSearchInputs returns true)
    // Transform dates inputs (from 'mm/yyyy' format to 'yymm' format)
    var aamm1 = aammTransformDate(this.state.initialDate);
    var aamm2 = "";
    if(this.state.oneMonth){
      aamm2 = aamm1;
    } else {
      aamm2 = aammTransformDate(this.state.finalDate);
    }
    
    // Query table
    queryEnergyTable(this.state.dynamo, this.state.tableName, this.state.chosenMeter, this.state.meters, aamm1, aamm2).then(queryResponse => {
      var newLocation = defineRoute(this.state.oneMonth, this.state.chosenMeter);
    
      // After query resolve
      if (!this.state.oneMonth) {
        // Period case
        // Build charConfigs object
        var chartConfigs = buildChartData(queryResponse, aamm1, aamm2);
        this.setState({
          queryResponse: queryResponse,
          chartConfigs: chartConfigs,
          showResult: true,
          error: false,
          newLocation: newLocation
        });
      } else {
        // One month case
        // TODO: INSERT FUNCTIONS TO MANIPULATE QUERYRESPONSE FOR ONE MONTH
        this.setState({
          queryResponse: queryResponse,
          showResult: true,
          error: false,
          newLocation: newLocation
        });
      }
    });
  // Browser display an alert message in case of wrong search inputs
  } else {
    alert("Por favor, escolha novos parâmetros de pesquisa");
  }
}




