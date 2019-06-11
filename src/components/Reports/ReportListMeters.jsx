import React, { Component } from "react";
import { Table } from "reactstrap";
import ReportCard from "../Cards/ReportCard";

class ReportListMeters extends Component {
  render() {

    let {
      meters,
      nonEmptyMeters
    } = this.props;
    
    return (
      <ReportCard
        title={"Lista de medidores"}
        titleColSize={12}
        subtitle={"Dados atuais"}
        bodyClass={"body-scroll"}
      >

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
            {meters.map(unit => (
              <React.Fragment key={unit.id.S}>
                {nonEmptyMeters.includes(parseInt(unit.med.N, 10) + 100) &&
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
      </ReportCard>
    );
  }
}

export default ReportListMeters;
