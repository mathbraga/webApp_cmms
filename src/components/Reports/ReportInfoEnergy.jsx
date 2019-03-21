import React, { Component } from "react";
import { Card, CardBody, Col, Row, Table, Badge, CardHeader } from "reactstrap";
import classNames from "classnames";

const rowNames = [
  { name: "Identificação CEB", attr: "idceb" },
  { name: "Classe", attr: "classe" },
  { name: "Subclasse", attr: "subclasse" },
  { name: "Grupo", attr: "grupo" },
  { name: "Subgrupo", attr: "subgrupo" },
  { name: "Ligação", attr: "lig" },
  { name: "Modalidade tarifária", attr: "modtar" },
  // { name: "Edificações", attr: "" },
  // { name: "Demanda contratada", attr: ""} --> ADD THIS ATTRIBUTE TO DB TABLE (ENERGYINFO)
  { name: "Contrato", attr: "ct" },
  { name: "Observações", attr: "obs" }
];

class ReportInfoEnergy extends Component {
  render() {
    return (
      <Card>
        <CardHeader>
          <i className="fa fa-align-justify" />{" "}
          <strong>Informações do medidor</strong>
        </CardHeader>
        <CardBody>
          <Table responsive size="sm">
            {/* <thead>
              <tr className="header-table">
                <th>Informações</th>
                <th />
              </tr>
            </thead> */}
            <tbody>
              {rowNames.map(info => (
                <tr>
                  <th>{info.name}</th>
                  <td>{this.props.result2.Items[0][info.attr].S}</td>
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
