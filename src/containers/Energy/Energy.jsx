import React, { Component } from "react";
import FormDates from "../../components/Forms/FormDates";
import { handleDates } from "../../utils/handleDates";
import EnergyResults from "./EnergyResults";
import { dynamoInit } from "../../utils/dynamoinit";
import handleSearch from "../../utils/handleSearch";
import { energyinfoinit } from "../../utils/energyinfoinit";

class Energy extends Component {
  constructor(props) {
    super(props);
    const dynamo = dynamoInit();
    this.state = {
      meters: [],
      dynamo: dynamo,
      tableName: "CEB",
      initialDate: "",
      finalDate: "",
      chosenMeter: "199",
      oneMonth: false,
      error: false,
      queryResponse: false,
      chartConfigs: {},
      showResult: false,
      newLocation: ""
    };
  }

  componentDidMount() {
    energyinfoinit(this.state.dynamo, "CEB-Medidores").then(data => {
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
    this.setState({
      showResult: false,
      initialDate: "",
      finalDate: "",
      chosenMeter: "199",
      oneMonth: false
    });
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
