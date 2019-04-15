import checkSearchInputs from "./checkSearchInputs";
import queryEnergyTable from "./queryEnergyTable";
import buildChartData from "./buildChartData";
import defineNewLocation from "./defineNewLocation";
import aammTransformDate from "./aammTransformDate";
import allMetersSum from "./allMetersSum";
import removeEmpty from "./removeEmpty";

export default function handleSearch() {
  // Check date inputs
  if (
    checkSearchInputs(
      this.state.initialDate,
      this.state.finalDate,
      this.state.oneMonth
    )
  ) {
    // Run code below in case of correct search parameters inputs (checkSearchInputs returns true)

    // Transform dates inputs (from 'mm/yyyy' format to 'yymm' format)
    var aamm1 = aammTransformDate(this.state.initialDate);
    var aamm2 = "";
    if (this.state.oneMonth) {
      aamm2 = aamm1;
    } else {
      aamm2 = aammTransformDate(this.state.finalDate);
    }

    // Define new location
    var newLocation = defineNewLocation(
      this.state.oneMonth,
      this.state.chosenMeter,
      this.state.initialDate,
      this.state.finalDate
    );

    // Query table
    queryEnergyTable(
      this.state.dynamo,
      this.state.tableName,
      this.state.chosenMeter,
      this.state.meters,
      aamm1,
      aamm2
    ).then(data => {
      var queryResponse = [];
      var queryResponseAll = [];
      var chartConfigs = {};
      // AM case
      if (this.state.chosenMeter === "199" && this.state.oneMonth) {
        let noEmpty = removeEmpty(data);
        queryResponseAll = data;
        queryResponse = allMetersSum(data);
        this.setState({
          noEmpty: noEmpty,
          queryResponseAll: queryResponseAll,
          queryResponse: queryResponse,
          showResult: true,
          error: false,
          newLocation: newLocation
        });
      }

      // AP case
      if (this.state.chosenMeter === "199" && !this.state.oneMonth) {
        queryResponseAll = data;
        let noEmpty = removeEmpty(data);
        queryResponse = data;
        chartConfigs = buildChartData(queryResponse, aamm1, aamm2);
        this.setState({
          noEmpty: noEmpty,
          queryResponseAll: queryResponseAll,
          queryResponse: queryResponse,
          chartConfigs: chartConfigs,
          showResult: true,
          error: false,
          newLocation: newLocation
        });
      }

      // OM case
      if (this.state.chosenMeter !== "199" && this.state.oneMonth) {
        queryResponse = data;
        this.setState({
          queryResponse: queryResponse,
          showResult: true,
          error: false,
          newLocation: newLocation
        });
      }

      // OP case
      if (this.state.chosenMeter !== "199" && !this.state.oneMonth) {
        queryResponse = data;
        chartConfigs = buildChartData(queryResponse, aamm1, aamm2);
        this.setState({
          queryResponse: queryResponse,
          showResult: true,
          error: false,
          newLocation: newLocation,
          chartConfigs: chartConfigs
        });
      }
    });

    // Browser display an alert message in case of wrong search inputs
  } else {
    alert("Por favor, escolha novos parâmetros de pesquisa");
  }
}
