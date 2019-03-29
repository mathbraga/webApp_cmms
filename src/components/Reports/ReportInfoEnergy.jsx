import React, { Component } from "react";
import { Card, CardBody, Col, Row, Table, CardHeader } from "reactstrap";

const rowNames = [
  { name: "Identificação CEB", attr: "idceb" },
  { name: "Nome do Medidor", attr: "nome" },
  { name: "Contrato", attr: "ct" },
  { name: "Classe", attr: "classe" },
  { name: "Subclasse", attr: "subclasse" },
  { name: "Grupo", attr: "grupo" },
  { name: "Subgrupo", attr: "subgrupo" },
  { name: "Ligação", attr: "lig" },
  { name: "Modalidade tarifária", attr: "modtar" },
  { name: "Demanda Contratada (FP/P)", attr: "dem" },
  { name: "Observações", attr: "obs" }
];

class ReportInfoEnergy extends Component {
  render() {
    return (
      <Card>
        <CardHeader>
          <Row>
            <Col md="12">
              <div className="calc-title">Informações do Medidor</div>
              <div className="calc-subtitle">Dados Atuais</div>
            </Col>
          </Row>
        </CardHeader>
        <CardBody>
          <Table responsive size="sm">
            <tbody>
              {rowNames.map(info =>
                info.attr === "dem" ? (
                  <tr>
                    <th>{info.name}</th>
                    <td>
                      {this.props.data["dcf"].N} kW - {this.props.data["dcp"].N}{" "}
                      kW
                    </td>
                  </tr>
                ) : this.props.data[info.attr] ? (
                  <tr>
                    <th>{info.name}</th>
                    <td>{this.props.data[info.attr].S}</td>
                  </tr>
                ) : (
                  ""
                )
              )}
            </tbody>
          </Table>
        </CardBody>
      </Card>
    );
  }
}

export default ReportInfoEnergy;
