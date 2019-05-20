import React, { Component } from "react";
import { Table } from "reactstrap";
import ReportCard from "../Cards/ReportCard";
// import { rowNames } from "./ReportInfo-Config";

class ReportInfo extends Component {
  render() {

    const {
      unit,
      rowNamesInfo
    } = this.props
  
    return (
      <ReportCard
        title={"Informações do medidor"}
        titleColSize={12}
        subtitle={"Dados atuais"}
      >
        <Table responsive size="sm">
          <tbody>
            {rowNamesInfo.map(info =>
              info.attr === "dem" ? (
                <tr key={info.attr}>
                  <th>{info.name}</th>
                  <td>
                    {unit["dcf"].S} kW - {unit["dcp"].S}{" "}
                    kW
                  </td>
                </tr>
              ) : unit[info.attr] ? (
                <tr key={info.attr}>
                  <th>{info.name}</th>
                  <td>{unit[info.attr].S}</td>
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

export default ReportInfo;
