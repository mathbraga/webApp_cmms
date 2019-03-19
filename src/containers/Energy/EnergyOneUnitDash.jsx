import React, { Component } from "react";
import { Card, CardHeader, CardBody, Row, Col, Button } from "reactstrap";
import WidgetEnergyUsage from "../../components/Widgets/WidgetEnergyUsage";
import WidgetEnergyDemand from "../../components/Widgets/WidgetEnergyDemand";
import WidgetEnergyProblem from "../../components/Widgets/WidgetEnergyProblem";
import ReportEnergyOneUnit from "../../components/Reports/ReportEnergyOneUnit";
import ReportInfoEnergy from "../../components/Reports/ReportInfoEnergy";
import ReportCalculationsEnergy from "../../components/Reports/ReportCalculationsEnergy";

class EnergyOneUnitDash extends Component {
  render() {
    return (
      <Card>
        <CardHeader>
          <Row>
            <Col md="6">
              <div className="widget-title dash-title">
                <h4>{this.props.result2.Items[0].idceb.S}</h4>
                <div className="dash-subtitle">Medidor: Unidades de Apoio</div>
              </div>
              <div className="widget-container-center">
                <div className="dash-title-info">
                  Período: <strong>Jan/2018</strong>
                </div>
                <div className="dash-title-info">
                  Ligação: <strong>VERDE</strong>
                </div>
              </div>
            </Col>
            <Col md="6" className="container-left">
              <Button color="ghost-primary" onClick={this.props.handleClick}>
                <i className="cui-magnifying-glass" />
                &nbsp;Nova Pesquisa
              </Button>
            </Col>
          </Row>
        </CardHeader>
        <CardBody>
          <Row>
            <Col md="3">
              <WidgetEnergyUsage />
            </Col>
            <Col md="6">
              <WidgetEnergyDemand />
            </Col>
            <Col md="3">
              <WidgetEnergyProblem />
            </Col>
          </Row>
          <Row>
            <Col md="6">
              <ReportInfoEnergy result2={this.props.result2} />
            </Col>
            <Col md="6">
              <ReportCalculationsEnergy />
            </Col>
          </Row>
          <Row>
            <Col>
              <ReportEnergyOneUnit result1={this.props.result1} />
            </Col>
          </Row>
        </CardBody>
      </Card>
    );
  }
}

export default EnergyOneUnitDash;
