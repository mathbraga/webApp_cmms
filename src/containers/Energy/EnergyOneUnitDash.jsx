import React, { Component } from "react";
import { Card, CardHeader, CardBody, Row, Col } from "reactstrap";
import WidgetEnergyUsage from "../../components/Widgets/WidgetEnergyUsage";

class EnergyOneUnitDash extends Component {
  state = {};
  render() {
    return (
      <Card>
        <CardHeader>
          <Row>
            <Col md="5">
              <h4>192.605-0</h4>
              <div className="dash-subtitle">
                Medidor(es): Unidades de Apoio
              </div>
            </Col>
          </Row>

          {/* <Col md="8">
            <Row>
              <Col md="2">
                <div>
                  <strong>Medidor:</strong>
                </div>
                <div>
                  <strong>Nome:</strong>
                </div>
              </Col>
              <Col md="4">
                <div>195.260-0</div>
                <div>Unidade de Apoio</div>
              </Col>
              <Col md="2" />
            </Row>
          </Col> */}
        </CardHeader>
        <CardBody>
          <Row>
            <Col md="3">
              <WidgetEnergyUsage />
            </Col>
          </Row>
        </CardBody>
      </Card>
    );
  }
}

export default EnergyOneUnitDash;
