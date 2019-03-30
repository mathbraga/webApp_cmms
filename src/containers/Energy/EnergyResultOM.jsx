import React, { Component } from "react";
import { Card, CardHeader, CardBody, Row, Col, Button } from "reactstrap";
import WidgetEnergyUsage from "../../components/Widgets/WidgetEnergyUsage";
import WidgetEnergyDemand from "../../components/Widgets/WidgetEnergyDemand";
import WidgetEnergyProblem from "../../components/Widgets/WidgetEnergyProblem";
import ReportEnergyOneUnit from "../../components/Reports/ReportEnergyOneUnit";
import ReportInfoEnergy from "../../components/Reports/ReportInfoEnergy";
import ReportCalculationsEnergy from "../../components/Reports/ReportCalculationsEnergy";
import { queryEnergyTable } from "../../utils/queryEnergyTable";
import { transformDateString } from "../../utils/transformDateString";
import ReportEnergyPeriod from "../../components/Reports/ReportEnergyPeriod";
import { Line } from 'react-chartjs-2';
import Chart from "../../components/Charts/Chart";

class EnergyResultOM extends Component {
  render() {
    // Variables
    // const { meters } = this.props.energyState;
    // const result = {
    //   unit: false,
    //   queryResponse: this.props.energyState.queryResponse[0].Items[0]
    // };
    // meters.forEach(item => {
    //   const number = parseInt(item.med.N) + 100;
    //   if (number.toString() === this.props.energyState.chosenMeter)
    //     result.unit = item;
    // });

    // const dateString = transformDateString(result.queryResponse.aamm);

    // if (result.queryResponse.tipo === 1) {
    //   result.queryResponse.dcf = result.queryResponse.dc;
    //   result.queryResponse.dcp = 0;
    // }

    return (
      <div>
        
        <h1>TODO: EnergyResultOM</h1>

        
      </div>
    );
  }
}

export default EnergyResultOM;