import checkSearchInputs from "./checkSearchInputs";
import queryEnergyTable from "./queryEnergyTable";
import buildChartData from "./buildChartData";
import defineNewLocation from "./defineNewLocation";
import aammTransformDate from "./aammTransformDate";
import allMetersSum from "./allMetersSum";
import ChartComponent from "react-chartjs-2";

export default function handleSearch() {
  // Check dates inputs
  if (
    checkSearchInputs(
      this.state.initialDate,
      this.state.finalDate,
      this.state.oneMonth
    )
  ) {
    // Run code below in case of correct search parameters inputs (checkSearchInputs returns true)

    // Define new location
    var newLocation = defineNewLocation(
      this.state.oneMonth,
      this.state.chosenMeter
    );

    // Transform dates inputs (from 'mm/yyyy' format to 'yymm' format)
    var aamm1 = aammTransformDate(this.state.initialDate);
    var aamm2 = "";
    if (this.state.oneMonth) {
      aamm2 = aamm1;
    } else {
      aamm2 = aammTransformDate(this.state.finalDate);
    }

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
      var charConfigs = {};
      console.log("data:");
      console.log(data);
      // AM case
      if (this.state.chosenMeter === "199" && this.state.oneMonth) {
        queryResponse = allMetersSum(data);
        console.log("AM:");
        console.log(queryResponse);
        this.setState({
          queryResponse: queryResponse,
          showResult: true,
          error: false,
          newLocation: newLocation
        });
      }

      // AP case
      if (this.state.chosenMeter === "199" && !this.state.oneMonth) {
        queryResponse = data;
        charConfigs = buildChartData(queryResponse, aamm1, aamm2);
        console.log("AP:");
        console.log(charConfigs);
        console.log(queryResponse);
        this.setState({
          queryResponse: queryResponse,
          charConfigs: charConfigs,
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
        charConfigs = buildChartData(queryResponse, aamm1, aamm2);
        this.setState({
          queryResponse: queryResponse,
          showResult: true,
          error: false,
          newLocation: newLocation
        });
      }
      console.log("QR");
      console.log(queryResponse);
    });

    // Browser display an alert message in case of wrong search inputs
  } else {
    alert("Por favor, escolha novos parâmetros de pesquisa");
  }
}
