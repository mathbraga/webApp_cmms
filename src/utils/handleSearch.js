import checkSearchInputs from "./checkSearchInputs";
import queryEnergyTable from "./queryEnergyTable";
import buildChartData from "./buildChartData";
import defineRoute from "./defineRoute";
import aammTransformDate from "./aammTransformDate";

export default function handleSearch(){

  // Check dates inputs
  if(checkSearchInputs(this.state.initialDate, this.state.finalDate, this.state.oneMonth)){
    
  // Run functions in case of correct search parameters inputs
    // Transform dates inputs (from 'mm/yyyy' format to 'yymm' format)
    var aamm1 = aammTransformDate(this.state.initialDate);
    var aamm2 = "";
    if(this.state.oneMonth){
      aamm2 = aamm1;
    } else {
      aamm2 = aammTransformDate(this.state.finalDate);
    }
    
    // Query table
    queryEnergyTable(this.state, aamm1, aamm2).then(queryResponse => {
      var newRoute = defineRoute(this.state.oneMonth, this.state.chosenMeter);
    
      // After query resolve, build chartConfigs object in case of period and change state
      if (!this.state.oneMonth) {
      var chartConfigs = buildChartData(queryResponse, aamm1, aamm2);
      this.setState({
        queryResponse: queryResponse,
        chartConfigs: chartConfigs,
        showResult: true,
        error: false,
        newRoute: newRoute
      });
    } else {

      // After query resolve, in case of one month, change state
      this.setState({
        queryResponse: queryResponse,
        showResult: true,
        error: false,
        newRoute: newRoute
      });
    }
    });
  
  // Browser display an alert message in case of wrong search inputs
  } else {
    alert("Por favor, escolha novos parâmetros de pesquisa");
  }
}




