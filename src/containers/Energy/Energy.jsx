import React, { Component, Suspense } from "react";
import FormDates from "../../components/Forms/FormDates";
import Chart from "../../components/Charts/Chart";
import SimpleTable from "../../components/Tables/SimpleTable";
import { CardColumns, CardGroup, Col, Row } from "reactstrap";
import { CustomTooltips } from "@coreui/coreui-plugin-chartjs-custom-tooltips";
import { handleDates } from "../../utils/handleDates";
import EnergyOneUnitDash from "./EnergyOneUnitDash";
import EnergyAllDash from "./EnergyAllDash";
import { dynamoInit } from "../../utils/dynamoinit";
import { queryEnergyTable } from "../../utils/queryEnergyTable";
import { energyinfoinit } from "../../utils/energyinfoinit";

const dynamo = dynamoInit();

class Energy extends Component {
  constructor(props) {
    super(props);
    this.state = {
      meters: [],
      dynamo: dynamo,
      initialDate: "",
      finalDate: "",
      chosenMeter: "199",
      oneMonth: false,
      error: false
    };
  }

  componentDidMount() {
    energyinfoinit(this.state.dynamo, "Meters").then(data => {
      this.setState({ meters: data });
    });
  }

  handleChangeOnDates = handleDates.bind(this);

  handleQuery = event => {
    this.setState({
      showResult: true
    });
  };

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
      showResult1: false,
      showResult2: false,
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
            <EnergyOneUnitDash
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
