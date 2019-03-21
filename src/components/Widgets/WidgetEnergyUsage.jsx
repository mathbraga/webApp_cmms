import React, { Component } from "react";
import { Card, CardBody, Col, Row } from "reactstrap";

class WidgetEnergyUsage extends Component {
  state = {};

  formatNumber(number, dig = 2) {
    return number.toLocaleString("pt-BR", { maximumFractionDigits: dig });
  }

  render() {
    return (
      <Card className="widget-container">
        <CardBody className="widget-body">
          <Row>
            <Col md="7" className="col-widget">
              <div className="widget-title">Consumo</div>
              <div>{this.formatNumber(this.props.data.kwh, 0)} kWh</div>
              <div className="widget-title" style={{ "padding-top": "5px" }}>
                Gasto
              </div>
              <div>R$ {this.formatNumber(this.props.data.vbru)}</div>
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
