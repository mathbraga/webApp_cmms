import React, { Component } from "react";
import { Card, CardHeader, CardBody, Row, Col, Button } from "reactstrap";
import WidgetEnergyUsage from "../../components/Widgets/WidgetEnergyUsage";
import WidgetEnergyDemand from "../../components/Widgets/WidgetEnergyDemand";
import WidgetEnergyProblem from "../../components/Widgets/WidgetEnergyProblem";
import ReportEnergyOneUnit from "../../components/Reports/ReportEnergyOneUnit";
import ReportInfoEnergy from "../../components/Reports/ReportInfoEnergy";
import ReportCalculationsEnergy from "../../components/Reports/ReportCalculationsEnergy";

const monthList = {
  "01": "Jan",
  "02": "Fev",
  "03": "Mar",
  "04": "Abr",
  "05": "Mai",
  "06": "Jun",
  "07": "Jul",
  "08": "Ago",
  "09": "Set",
  "10": "Out",
  "11": "Nov",
  "12": "Dez"
};

class EnergyOneUnitDash extends Component {
  constructor(props) {
    super(props);
    this.dateString =
      monthList[props.result1.Items[0].aamm.toString().slice(2)] +
      "/20" +
      props.result1.Items[0].aamm.toString().slice(0, 2);
  }

  render() {
    return (
      <Card>
        <CardHeader>
          <Row>
            <Col md="6">
              <div className="widget-title dash-title">
                <h4>{this.props.result2.Items[0].idceb.S}</h4>
                <div className="dash-subtitle">
                  Medidor: <strong>**Unidades de Apoio**</strong>
                </div>
              </div>
              <div className="widget-container-center">
                <div className="dash-title-info">
                  Período: <strong>{this.dateString}</strong>
                </div>
                <div className="dash-title-info">
                  Ligação:{" "}
                  <strong>{this.props.result2.Items[0].modtar.S}</strong>
                </div>
              </div>
            </Col>
            <Col md="4" />
            <Col md="2" className="container-left">
              <Button
                block
                outline
                color="primary"
                onClick={this.props.handleClick}
              >
                <i className="cui-magnifying-glass" />
                &nbsp;Nova Pesquisa
              </Button>
            </Col>
          </Row>
        </CardHeader>
        <CardBody>
          <Row>
            <Col md="3">
              <WidgetEnergyUsage data={this.props.result1.Items[0]} />
            </Col>
            <Col md="6">
              <WidgetEnergyDemand data={this.props.result1.Items[0]} />
            </Col>
            <Col md="3">
              <WidgetEnergyProblem data={this.props.result1.Items[0]} />
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
              <ReportEnergyOneUnit data={this.props.result1.Items[0]} />
            </Col>
          </Row>
        </CardBody>
      </Card>
    );
  }
}

export default EnergyOneUnitDash;
