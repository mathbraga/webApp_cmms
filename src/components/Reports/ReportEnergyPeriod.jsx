import React, { Component } from "react";
import { Card, CardBody, Col, Row, Table, Badge, CardHeader } from "reactstrap";
import classNames from "classnames";

class ReportEnergyOneUnit extends Component {
  constructor(props){
    super(props);
  }

  formatNumber(number) {
    return number.toLocaleString("pt-BR", { maximumFractionDigits: 2 });
  }

  render() {
    return (
      <Card>
        <CardHeader>
         CARDHEADER
        </CardHeader>
        <CardBody>
          <Table responsive size="sm">
            <thead>
              <tr className="header-table">
                <th></th>
                {Object.keys(this.props.chartConfigs).map(key => (
                  <th>{this.props.chartConfigs[key].options.title.text}</th>
                ))}
              </tr>
            </thead>
            
            <tbody>
              {this.props.chartConfigs.vbru.data.labels.map((month, index) => (
                <tr>
                  <td>{month}</td>
                  {Object.keys(this.props.chartConfigs).map(key => (
                    <td>
                      {this.props.chartConfigs[key].data.datasets[0].data[index]}
                    </td>
                  ))}
                </tr>
              ))}


            </tbody>
          </Table>
        </CardBody>
      </Card>
    );
  }
}

export default ReportEnergyOneUnit;
