import React, { Component, Suspense } from "react";
import FormDates from "../../components/Forms/FormDates";
import Chart from "../../components/Charts/Chart";
import SimpleTable from "../../components/Tables/SimpleTable";
import { CardColumns, CardGroup, Col, Row } from "reactstrap";
import { CustomTooltips } from "@coreui/coreui-plugin-chartjs-custom-tooltips";
import { handleDates } from "../../utils/handleDates";
import EnergyOneUnitDash from "./EnergyOneUnitDash";
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
      tableName: "EnergyTable",
      initialDate: "",
      finalDate: "",
      chosenMeter: "199",
      oneMonth: false,
      error: false,
      queryResponse: false,
      chartConfigs: {},
      showResult: false,
      newRoute: ""
    };
  }

  componentDidMount() {
    energyinfoinit(this.state.dynamo, "Meters").then(data => {
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
              handleClick={this.showFormDates}
              energyState={this.state}
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
