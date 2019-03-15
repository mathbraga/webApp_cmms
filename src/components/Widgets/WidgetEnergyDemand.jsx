import React, { Component } from "react";
import { Card, CardBody, Col, Row } from "reactstrap";

class WidgetEnergyDemand extends Component {
  state = {};
  render() {
    return (
      <Card className="widget-container">
        <CardBody className="widget-body">
          <Row className="widget-container-text">
            <Col md="3">
              <div className="widget-title">Demanda P</div>
              <div>100 kW</div>
              <div className="widget-title" style={{ "padding-top": "5px" }}>
                Demanda FP
              </div>
              <div>120 kW</div>
            </Col>
            <Col md="3">
              <div className="widget-division">
                <div className="widget-title">Contrato P</div>
                <div>150 kW</div>
                <div className="widget-title" style={{ "padding-top": "5px" }}>
                  Contrato FP
                </div>
                <div>180 kW</div>
              </div>
            </Col>
            <Col md="3">
              <div className="widget-division">
                <div className="widget-title">Faturado P</div>
                <div>150 kW</div>
                <div className="widget-title" style={{ "padding-top": "5px" }}>
                  Faturado FP
                </div>
                <div>180 kW</div>
              </div>
            </Col>
            <Col md="3" className="widget-container-image">
              <img
                className="widget-image"
                src={require("../../assets/icons/iconfinder_a_5_2578124.png")}
              />
            </Col>
          </Row>
        </CardBody>
      </Card>
    );
  }
}

export default WidgetEnergyDemand;
