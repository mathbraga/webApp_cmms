import React, { Component } from "react";
import { Table } from "reactstrap";
import ReportCard from "../Cards/ReportCard";

class ReportListMeters extends Component {
  render() {
    return (
      <ReportCard
        title={"Lista de Medidores"}
        titleColSize={12}
        subtitle={"Dados Atuais"}
        bodyClass={"body-scroll"}
      >

      {this.props.resultType === "energy" &&
        <Table responsive size="sm">
          <thead>
            <tr>
              <th />
              <th>Medidor</th>
              <th>Modalidade</th>
              <th>Demanda (FP / P)</th>
            </tr>
          </thead>
          <tbody>
            {this.props.meters.map(unit => (
              <React.Fragment key={unit.id.S}>
                {this.props.nonEmptyMeters.includes(parseInt(unit.med.N, 10) + 100) &&
                  <tr>
                    <th>{unit.id.S}</th>
                    <td>{unit.nome.S}</td>
                    <td>{unit.modtar.S}</td>
                    {unit.dcf.S == 0 && unit.dcp.S == 0 ? (
                      <td>-</td>
                    ) : (
                      <td>
                        {unit.dcf.S && parseInt(unit.dcf.S) > 0 ? unit.dcf.S : "-"}{" "}
                        kW /{" "}
                        {unit.dcp.S && parseInt(unit.dcp.S) > 0 ? unit.dcp.S : "-"}{" "}
                        kW
                      </td>
                    )}
                  </tr>
                }
              </React.Fragment>
            ))}
          </tbody>
        </Table>
      }
      
      {this.props.resultType === "water" &&
        <Table responsive size="sm">
          <thead>
            <tr>
              <th>Medidor</th>
              <th>Nome</th>
              <th>Hidrômetro</th>
              <th>Locais</th>
            </tr>
          </thead>
          <tbody>
            {this.props.meters.map(unit => (
              <React.Fragment key={unit.id.S}>
                {this.props.nonEmptyMeters.includes(parseInt(unit.med.N, 10) + 200) &&
                  <tr>
                    <th>{unit.id.S}</th>
                    <td>{unit.nome.S}</td>
                    <td>{unit.hidrom.S}</td>
                    <td>{unit.locais.S}</td>
                  </tr>
                }
              </React.Fragment>
            ))}
          </tbody>
        </Table>      
      }
      </ReportCard>
    );
  }
}

export default ReportListMeters;
