import React, { Component } from "react";
import FormDates from "../../components/Forms/FormDates";
import { handleDates } from "../../utils/handleDates";
import EnergyResults from "./EnergyResults";
import { dynamoInit } from "../../utils/dynamoInit";
import handleSearch from "../../utils/handleSearch";
import getAllMeters from "../../utils/getAllMeters";

class Energy extends Component {
  constructor(props) {
    super(props);
    const dynamo = dynamoInit();
    this.state = {
      noEmpty: [],
      meters: [],
      dynamo: dynamo,
      tableName: "CEB",
      tableNameMeters: "CEB-Medidores",
      tipomed: "1",
      initialDate: "",
      finalDate: "",
      chosenMeter: "199",
      oneMonth: false,
      error: false,
      queryResponse: false,
      queryResponseAll: false,
      chartConfigs: {},
      showResult: false,
      newLocation: ""
    };
  }

  componentDidMount() {
    getAllMeters(this.state.dynamo, this.state.tableNameMeters, this.state.tipomed).then(data => {
      this.setState({ meters: data });
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
      chosenMeter: "199",
      oneMonth: prevState.oneMonth
    }));
  };

  render() {
    return (
      <div>
        <div>
          {this.state.showResult ? (
            <EnergyResults
              energyState={this.state}
              handleClick={this.showFormDates}
            />
          ) : (
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
          )}
        </div>
      </div>
    );
  }
}

export default Energy;
