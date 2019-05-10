import checkSearchInputs from "./checkSearchInputs";
import queryTable from "./queryTable";
import defineNewLocation from "./defineNewLocation";
import aammTransformDate from "./aammTransformDate";
import sumAllMeters from "./sumAllMeters";
import removeEmptyMeters from "./removeEmptyMeters";
import makeChartConfigs from "./makeChartConfigs";

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
      this.state.finalDate,
      this.meterType
    );

    // Query table
    queryTable(
      this.state.dbObject,
      this.tableName,
      this.state.chosenMeter,
      this.state.meters,
      aamm1,
      aamm2
    ).then(data => {
      var queryResponse = [];
      var queryResponseAll = [];
      var chartConfigs = {};
      var nonEmptyMeters = [];
      // AM case
      if (this.state.chosenMeter === this.meterType + "99" && this.state.oneMonth) {
        nonEmptyMeters = removeEmptyMeters(data);
        queryResponseAll = data;
        queryResponse = sumAllMeters(data, this.meterType);
        this.setState({
          nonEmptyMeters: nonEmptyMeters,
          queryResponseAll: queryResponseAll,
          queryResponse: queryResponse,
          showResult: true,
          error: false,
          newLocation: newLocation
        });
      }

      // AP case
      if (this.state.chosenMeter === this.meterType + "99" && !this.state.oneMonth) {
        queryResponseAll = data;
        nonEmptyMeters = removeEmptyMeters(data);
        queryResponse = data;
        chartConfigs = makeChartConfigs(queryResponse, aamm1, aamm2, this.meterType);
        this.setState({
          nonEmptyMeters: nonEmptyMeters,
          queryResponseAll: queryResponseAll,
          queryResponse: queryResponse,
          chartConfigs: chartConfigs,
          showResult: true,
          error: false,
          newLocation: newLocation
        });
      }

      // OM case
      if (this.state.chosenMeter !== this.meterType + "99" && this.state.oneMonth) {
        queryResponse = data;
        if(queryResponse[0].Items.length === 0){
          alert("NÃO HÁ DADOS PARA O MEDIDOR NO PERÍODO PESQUISADO.\n\nPor favor, escolha novos parâmetros de pesquisa");
          this.setState({
            error: true,
          });
        } else {
          this.setState({
            queryResponse: queryResponse,
            showResult: true,
            error: false,
            newLocation: newLocation
          });
        }
      }

      // OP case
      if (this.state.chosenMeter !== this.meterType + "99" && !this.state.oneMonth) {
        queryResponse = data;
        chartConfigs = makeChartConfigs(queryResponse, aamm1, aamm2, this.meterType);
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
