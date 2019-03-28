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

class EnergyResultAM extends Component {
  render() {
    return (
      <div>
        
        <h1>TODO: EnergyResultAM</h1>

        
      </div>
    );
  }
}

export default EnergyResultAM;