import React, { Component } from "react";
import { Card, CardBody, Col, Row, Table, Badge, CardHeader } from "reactstrap";
import classNames from "classnames";

const rowNames = [
  { name: "Nome", value: "Unidades de Apoio" },
  { name: "Número de Identificação", value: "192.605-0" },
  { name: "Contrato", value: "CT 112/2018" },
  { name: "Endereço", value: "Via N2" },
  { name: "Edíficios Alimentados", value: "Bloco 1, Bloco 2, Bloco 3" },
  { name: "Tipo de Ligação", value: "Verde" },
  { name: "Demanda Contratada Ponta", value: "110 kW" },
  { name: "Demanda Contratada Ponta", value: "120 kW" }
];

class ReportInfoEnergy extends Component {
  state = {};
  render() {
    return (
      <Card>
        <CardHeader>
          <i className="fa fa-align-justify" />{" "}
          <strong>Informações Gerais</strong>
        </CardHeader>
        <CardBody>
          <Table responsive size="sm">
            <thead>
              <tr className="header-table">
                <th>Informações</th>
                <th />
              </tr>
            </thead>
            <tbody>
              {rowNames.map(info => (
                <tr>
                  <th>{info.name}</th>
                  <td>{info.value}</td>
                </tr>
              ))}
            </tbody>
          </Table>
        </CardBody>
      </Card>
    );
  }
}

export default ReportInfoEnergy;
