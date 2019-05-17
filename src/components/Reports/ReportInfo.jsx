import React, { Component } from "react";
import { Table } from "reactstrap";
import ReportCard from "../Cards/ReportCard";
import { rowNames } from "./ReportInfo-Config";

class ReportInfo extends Component {
  render() {

    let resultType = "";
    switch(this.props.meterType){
      case("1") : resultType = "energy";break;
      case("2") : resultType = "water";break;
    }
  
    return (
      <ReportCard
        title={"Informações do medidor"}
        titleColSize={12}
        subtitle={"Dados atuais"}
      >
        <Table responsive size="sm">
          <tbody>
            {rowNames[resultType].map(info =>
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
