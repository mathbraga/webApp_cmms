import React, { Component } from "react";
import { Card, CardBody, Col, Row } from "reactstrap";

class WidgetEnergyUsage extends Component {
  state = {};
  render() {
    return (
      <Card className="widget-container">
        <CardBody className="widget-body">
          <Row>
            <Col md="7" className="col-widget">
              <div className="widget-title">Consumo</div>
              <div>1.200 kWh</div>
              <div className="widget-title" style={{ "padding-top": "5px" }}>
                Gasto
              </div>
              <div>R$ 12.000,00</div>
            </Col>
            <Col md="5" className="widget-container-image">
              <img
                className="widget-image"
                src={require("../../assets/icons/iconfinder_Moneyidea_2103632.png")}
              />
            </Col>
          </Row>
        </CardBody>
      </Card>
    );
  }
}

export default WidgetEnergyUsage;
