import React, { Component } from "react";
import { Card, CardBody, Col, Row, Table, CardHeader } from "reactstrap";
import ReportCard from "../Cards/ReportCard";

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
  { name: "Locais", attr: "locais" },
  { name: "Demanda Contratada (FP/P)", attr: "dem" },
  { name: "Observações", attr: "obs" }
];

class ReportInfoEnergy extends Component {
  render() {
    console.log("InfoEnergy:");
    console.log(this.props.data);
    return (
      <ReportCard
        title={"Informações do Medidor"}
        titleColSize={12}
        subtitle={"Dados Atuais"}
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
