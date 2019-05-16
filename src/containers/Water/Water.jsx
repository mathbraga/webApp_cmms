import React, { Component } from "react";
import FormDates from "../../components/Forms/FormDates";
import FileInput from "../../components/FileInputs/FileInput"
import WaterResults from "./WaterResults";
import handleDates from "../../utils/energy/handleDates";
import initializeDynamoDB from "../../utils/energy/initializeDynamoDB";
import handleSearch from "../../utils/energy/handleSearch";
import getAllMeters from "../../utils/energy/getAllMeters";

class Water extends Component {
  constructor(props) {
    super(props);
    this.tableName = "CAESBteste";
    this.tableNameMeters = "CAESB-Medidores";
    this.meterType = "2";
    this.defaultMeter = this.meterType + "99";
    this.state = {
      tableName: this.tableName,
      nonEmptyMeters: [],
      meters: [],
      dbObject: initializeDynamoDB(),
      initialDate: "",
      finalDate: "",
      chosenMeter: "299",
      oneMonth: false,
      error: false,
      queryResponse: false,
      queryResponseAll: false,
      chartConfigs: {},
      showResult: false,
      newLocation: "",
    };
  }

  componentDidMount() {
    getAllMeters(this.state.dbObject, this.tableNameMeters, this.meterType).then(meters => {
      this.setState({
        meters: meters
      });
    });
  }

  handleChangeOnDates = handleDates.bind(this);
  
  handleQuery = event => {
    handleSearch(this.state.initialDate, this.state.finalDate, this.state.oneMonth, this.state.chosenMeter, this.meterType, this.state.meters, this.state.dbObject, this.state.tableName).then(newState => {
      this.setState(newState);
    }).catch(() => {
      alert("Houve um problema. Por favor, escolha novos parâmetros de pesquisa.");
    }); 
  }

  handleOneMonth = event => {
    this.setState({
      oneMonth: event.target.checked
    });
  };

  handleMeterChange = event => {
    this.setState({
      chosenMeter: event.target.value
    });
  };

  showFormDates = event => {
    this.setState((prevState, props) => ({
      showResult: false,
      initialDate: prevState.initialDate,
      finalDate: prevState.finalDate,
      chosenMeter: "299",
      oneMonth: prevState.oneMonth
    }));
  };

  render() {
    return (
      <>
        {this.state.showResult ? (
          <WaterResults
            waterState={this.state}
            handleClick={this.showFormDates}
          />
        ) : (
          <>
            <FormDates
              onChangeDate={this.handleChangeOnDates}
              initialDate={this.state.initialDate}
              finalDate={this.state.finalDate}
              oneMonth={this.state.oneMonth}
              meters={this.state.meters}
              onChangeOneMonth={this.handleOneMonth}
              onMeterChange={this.handleMeterChange}
              onQuery={this.handleQuery}
            />
            <FileInput
              tableName={this.state.tableName}
              dbObject={this.state.dbObject}
            />
          </>
        )}
      </>
    );
  }
}

export default Water;