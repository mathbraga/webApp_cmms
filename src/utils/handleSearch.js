import checkSearchInputs from "./checkSearchInputs";
import queryEnergyTable from "./queryEnergyTable";
import buildChartData from "./buildChartData";
import defineRoute from "./defineRoute";

export default function handleSearch(){

  var month1 = this.state.initialDate.slice(5) + this.state.initialDate.slice(0, 2);
  var month2 = "";
  if (this.state.oneMonth) {
    month2 = month1;
  } else {
    month2 = this.state.finalDate.slice(5) + this.state.finalDate.slice(0, 2);
  }


  
  if(checkSearchInputs(this.state.initialDate, this.state.finalDate, month1, month2, this.state.oneMonth)){
    queryEnergyTable(this.state, month1, month2).then(queryResponse => {
      var newRoute = defineRoute(this.state.oneMonth, this.state.chosenMeter);
    if (!this.state.oneMonth) {
      var chartConfigs = buildChartData(queryResponse, month1, month2);
      this.setState({
        queryResponse: queryResponse,
        chartConfigs: chartConfigs,
        showResult: true,
        error: false,
        newRoute: newRoute
      });
    } else {
      this.setState({
        queryResponse: queryResponse,
        showResult: true,
        error: false,
        newRoute: newRoute
      });
    }
    });
    
  } else {
    alert("Por favor, escolha novos parâmetros de pesquisa");
  }
}




