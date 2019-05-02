import React, { Component } from "react";
import { Card, CardHeader, CardBody, Row, Col, Button } from "reactstrap";
import WidgetOneColumn from "../../components/Widgets/WidgetOneColumn";
import WidgetThreeColumns from "../../components/Widgets/WidgetThreeColumns";
import WidgetWithModal from "../../components/Widgets/WidgetWithModal";
import ReportEnergyOneUnit from "../../components/Reports/ReportEnergyOneUnit";
import ReportInfoEnergy from "../../components/Reports/ReportInfoEnergy";
import ReportCalculationsEnergy from "../../components/Reports/ReportCalculationsEnergy";
import { transformDateString } from "../../utils/energy/transformDateString";

class EnergyOneUnitDash extends Component {
  render() {
    // Variables
    const { meters } = this.props.energyState;
    const result = {
      unit: false,
      queryResponse: this.props.energyState.queryResponse[0].Items[0]
    };
    meters.forEach(item => {
      const number = parseInt(item.med.N) + 100;
      if (number.toString() === this.props.energyState.chosenMeter)
        result.unit = item;
    });

    const dateString = transformDateString(result.queryResponse.aamm);

    if (result.queryResponse.tipo === 1) {
      result.queryResponse.dcf = result.queryResponse.dc;
      result.queryResponse.dcp = 0;
    }

    return (
      <div>
        <Card>
          <CardHeader>
            <Row>
              <Col md="6">
                <div className="widget-title dash-title">
                  <h4>{result.unit.idceb.S}</h4>

                  <div className="dash-subtitle">
                    Medidor: <strong>{result.unit.nome.S}</strong>
                  </div>
                </div>
                <div className="widget-container-center">
                  <div className="dash-title-info">
                    Período: <strong>{dateString}</strong>
                  </div>
                  <div className="dash-title-info">
                    Modalidade: <strong>{result.unit.modtar.S}</strong>
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
                <WidgetOneColumn data={result.queryResponse} />
              </Col>
              <Col md="6">
                <WidgetThreeColumns data={result.queryResponse} />
              </Col>
              <Col md="3">
                <WidgetWithModal data={result} />
              </Col>
            </Row>
            <Row>
              <Col md="6">
                <ReportInfoEnergy data={result.unit} date={dateString} />
              </Col>
              <Col md="6">
                <ReportCalculationsEnergy
                  dbObject={this.props.energyState.dynamo}
                  consumer={this.props.energyState.chosenMeter}
                  dateString={dateString}
                  data={result.queryResponse}
                  demandContract={result.unit}
                />
              </Col>
            </Row>
            <Row>
              <Col>
                <ReportEnergyOneUnit
                  data={result.queryResponse}
                  dateString={dateString}
                  dbObject={this.props.energyState.dynamo}
                  consumer={this.props.energyState.chosenMeter}
                  date={result.queryResponse.aamm}
                />
              </Col>
            </Row>
          </CardBody>
        </Card>
      </div>
    );
  }
}

export default EnergyOneUnitDash;
