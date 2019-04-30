import React, { Component } from "react";
import { Card, CardBody, Col, Row, Table, CardHeader } from "reactstrap";
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
              <>
                {this.props.noEmpty.includes(parseInt(unit.med.N, 10) + 100) &&
                  <tr>
                    <th>{unit.idceb.S}</th>
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
              </>
            ))}
          </tbody>
        </Table>
      </ReportCard>
    );
  }
}

export default ReportListMeters;
