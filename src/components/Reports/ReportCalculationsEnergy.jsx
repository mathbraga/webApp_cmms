import React, { Component } from "react";
import { Card, CardBody, Col, Row, Table, Badge, CardHeader } from "reactstrap";
import classNames from "classnames";

class ReportCalculationsEnergy extends Component {
  state = {};
  render() {
    return (
      <Card>
        <CardHeader>
          <i className="fa fa-align-justify" /> <strong>Cálculos</strong>
        </CardHeader>
        <CardBody>
          <Table responsive borderless size="sm">
            <tbody>
              <tr>
                <th className="main-table">Demanda</th>
                <th className="main-table">Ponta</th>
                <th className="main-table">Fora de Ponta</th>
                <th />
              </tr>
              <tr>
                <th className="sub-2-table">Valor Ideal</th>
                <td>110 kW</td>
                <td>110 kW</td>
                <td />
              </tr>
              <tr>
                <th className="sub-2-table">Valor Atual</th>
                <td>110 kW</td>
                <td>110 kW</td>
                <td>Ok</td>
              </tr>
            </tbody>
          </Table>
        </CardBody>
      </Card>
    );
  }
}

export default ReportCalculationsEnergy;
