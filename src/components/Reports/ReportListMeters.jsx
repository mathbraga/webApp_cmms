import React, { Component } from "react";
import { Card, CardBody, Col, Row, Table, CardHeader } from "reactstrap";
import ReportCard from "../Cards/ReportCard";

class ReportInfoEnergy extends Component {
  render() {
    return (
      <ReportCard
        title={"Lista de Medidores"}
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
      </ReportCard>
    );
  }
}

export default ReportInfoEnergy;
