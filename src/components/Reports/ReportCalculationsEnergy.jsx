import React, { Component } from "react";
import {
  Card,
  CardBody,
  Col,
  Row,
  Table,
  Badge,
  CardHeader,
  CardTitle
} from "reactstrap";
import classNames from "classnames";
import DoubleBarChart from "../Charts/DoubleBarChart";

class ReportCalculationsEnergy extends Component {
  state = {};
  render() {
    return (
      <Card>
        <CardHeader>
          <i className="fa fa-align-justify" /> <strong>Cálculos</strong>
        </CardHeader>
        <CardBody>
          <CardTitle>
            <div className="calc-title">Demanda Ideal</div>
            <div className="calc-subtitle">
              Mês do Cálculo: <strong>Jan/2018</strong>
            </div>
          </CardTitle>
          <Row>
            <Col md="6">
              <div className="container-demand">
                <div className="demand-new">200 kW</div>
                <div className="demand-subtitle">
                  <strong>Ponta</strong> - Valor Ideal
                </div>
              </div>
            </Col>
            <Col md="6">
              <div className="container-demand">
                <div className="demand-new">200 kW</div>
                <div className="demand-subtitle">
                  <strong>Fora Ponta</strong> - Valor Ideal
                </div>
              </div>
            </Col>
          </Row>
          <Row>
            <Col md="6">
              <div className="container-old-demand">
                <div className="demand-value">200 kW</div>
                <div className="demand-subtitle">
                  <strong>Ponta</strong> - Valor Contratado
                </div>
              </div>
            </Col>
            <Col md="6">
              <div className="container-old-demand">
                <div className="demand-value">200 kW</div>
                <div className="demand-subtitle">
                  <strong>Fora Ponta</strong> - Valor Contratado
                </div>
              </div>
            </Col>
          </Row>
        </CardBody>
      </Card>
    );
  }
}

export default ReportCalculationsEnergy;
