import React, { Component } from "react";
import { Card, CardBody, Col, Row } from "reactstrap";

class WidgetEnergyDemand extends Component {
  state = {};

  formatNumber(number) {
    return number.toLocaleString("pt-BR", { maximumFractionDigits: 2 });
  }

  render() {
    return (
      <Card className="widget-container">
        <CardBody className="widget-body">
          <Row className="widget-container-text">
            <Col md="3">
              <div className="widget-title">Demanda FP</div>
              <div>{this.props.data.dmf} kW</div>
              <div className="widget-title" style={{ "padding-top": "5px" }}>
                Demanda P
              </div>
              <div>{this.props.data.dmp} kW</div>
            </Col>
            <Col md="3">
              <div className="widget-division">
                <div className="widget-title">Contrato FP</div>
                <div>{this.props.data.dcf} kW</div>
                <div className="widget-title" style={{ "padding-top": "5px" }}>
                  Contrato P
                </div>
                <div>{this.props.data.dcp} kW</div>
              </div>
            </Col>
            <Col md="3">
              <div className="widget-division">
                <div className="widget-title">Faturado FP</div>
                <div>{this.props.data.dff} kW</div>
                <div className="widget-title" style={{ "padding-top": "5px" }}>
                  Faturado P
                </div>
                <div>{this.props.data.dfp} kW</div>
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
