import React, { Component } from "react";
import { Table } from "reactstrap";
import ReportCard from "../Cards/ReportCard";
// import { rowNames } from "./ReportInfo-Config";

class ReportInfo extends Component {
  render() {

    const {
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
                    {this.props.data["dcf"].S} kW - {this.props.data["dcp"].S}{" "}
                    kW
                  </td>
                </tr>
              ) : this.props.data[info.attr] ? (
                <tr key={info.attr}>
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

export default ReportInfo;
