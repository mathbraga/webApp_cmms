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
          <CardTitle>Demanda Contratada</CardTitle>
          <Row>
            <Col md="6">
              <div>
                <div>200 kW</div>
                <div>
                  <strong>Ponta</strong> - Valor Ideal
                </div>
              </div>
            </Col>
            <Col md="6">
              <div>200 kW</div>
              <div>
                <strong>Ponta</strong> - Valor Atual
              </div>
            </Col>
          </Row>
          <Row>
            <Col md="6">
              <div>200 kW</div>
              <div>
                <strong>Fora Ponta</strong> - Valor Ideal
              </div>
            </Col>
            <Col md="6">
              <div>200 kW</div>
              <div>
                <strong>Fora Ponta</strong> - Valor Ideal
              </div>
            </Col>
          </Row>
        </CardBody>
      </Card>
    );
  }
}

export default ReportCalculationsEnergy;
