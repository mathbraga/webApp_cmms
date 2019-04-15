import React, { Component } from "react";
import { Card, CardBody, Col, Row, Table, CardHeader } from "reactstrap";
import ReportCard from "../Cards/ReportCard";

const rowNames = [
  { name: "Identificação CEB", attr: "idceb" },
  { name: "Nome do medidor", attr: "nome" },
  { name: "Contrato", attr: "ct" },
  { name: "Classe", attr: "classe" },
  { name: "Subclasse", attr: "subclasse" },
  { name: "Grupo", attr: "grupo" },
  { name: "Subgrupo", attr: "subgrupo" },
  { name: "Ligação", attr: "lig" },
  { name: "Modalidade tarifária", attr: "modtar" },
  { name: "Locais", attr: "locais" },
  { name: "Demanda contratada (FP/P)", attr: "dem" },
  { name: "Observações", attr: "obs" }
];

class ReportInfoEnergy extends Component {
  render() {
    return (
      <ReportCard
        title={"Informações do medidor"}
        titleColSize={12}
        subtitle={"Dados atuais"}
      >
        <Table responsive size="sm">
          <tbody>
            {rowNames.map(info =>
              info.attr === "dem" ? (
                <tr>
                  <th>{info.name}</th>
                  <td>
                    {this.props.data["dcf"].S} kW - {this.props.data["dcp"].S}{" "}
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
      </ReportCard>
    );
  }
}

export default ReportInfoEnergy;
