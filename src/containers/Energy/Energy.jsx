import React, { Component } from "react";
import FormDates from "../../components/Forms/FormDates";
import FileInput from "../../components/FileInputs/FileInput"
import EnergyResults from "./EnergyResults";
import handleDates from "../../utils/energy/handleDates";
import initializeDynamoDB from "../../utils/energy/initializeDynamoDB";
import handleSearch from "../../utils/energy/handleSearch";
import getAllMeters from "../../utils/energy/getAllMeters";

class Energy extends Component {
  constructor(props) {
    super(props);
    this.tableName = "CEBteste";
    this.tableNameMeters = "CEB-Medidoresteste";
    this.meterType = "1";
    this.defaultMeter = this.meterType + "99";
    this.state = {
      tableName: this.tableName,
      nonEmptyMeters: [],
      meters: [],
      dbObject: initializeDynamoDB(),
      initialDate: "",
      finalDate: "",
      chosenMeter: "199",
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
      chosenMeter: this.defaultMeter,
      oneMonth: prevState.oneMonth
    }));
  };

  render() {
    return (
      <React.Fragment>
        {this.state.showResult ? (
          <EnergyResults
            energyState={this.state}
            handleClick={this.showFormDates}
          />
        ) : (
          <React.Fragment>
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
          </React.Fragment>
        )}
      </React.Fragment>
    );
  }
}

export default Energy;
