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
    this.tableName = "CEB";
    this.tableNameMeters = "CEB-Medidores";
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
  handleQuery = handleSearch.bind(this);

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
      <>
        {this.state.showResult ? (
          <EnergyResults
            energyState={this.state}
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

export default Energy;
