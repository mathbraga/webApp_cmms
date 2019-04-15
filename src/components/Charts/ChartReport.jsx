import React, { Component } from "react";
import { Row, Col, Table } from "reactstrap";
import { Line } from "react-chartjs-2";
import { formatNumber } from "../../utils/formatText";
import ReportCard from "../Cards/ReportCard";

class ChartReport extends Component {
  // Props:
  //      - medName (string): Number of this unit

  constructor(props) {
    super(props);
    this.state = {
      selected: "vbru"
    };
  }

  onChangeYAxis = type => {
    this.setState({ selected: type });
  };

  render() {
    const { medName, itemsForChart } = this.props;
    let dropdowItems = {};
    itemsForChart.forEach(key => {
      dropdowItems[key] = this.props.energyState.chartConfigs[
        key
      ].options.title.text;
    });

    return (
      <ReportCard
        title={"Gráfico do Período"}
        titleColSize={3}
        subtitle={"Medidor:"}
        subvalue={medName}
        dropdown
        dropdownTitle={"Ver resultado para:"}
        dropdownItems={dropdowItems}
        showCalcResult={this.onChangeYAxis}
        resultID={this.state.selected}
        bodyClass="fixed-height"
      >
        <Row>
          {/*Gráfico*/}
          <Col md="8">
            <Line
              data={
                this.props.energyState.chartConfigs[this.state.selected].data
              }
              options={
                this.props.energyState.chartConfigs[this.state.selected].options
              }
              redraw={true}
            />
          </Col>

          {/*Tabela*/}
          <Col md="4" className="table-container">
            <Table responsive size="sm" className="center">
              <thead>
                <tr>
                  <th>Mês</th>
                  <th>
                    {this.props.energyState.chartConfigs[this.state.selected]
                      .options.title.text +
                      " (" +
                      this.props.energyState.chartConfigs[this.state.selected]
                        .options.scales.yAxes[0].scaleLabel.labelString +
                      ")"}
                  </th>
                </tr>
              </thead>
              <tbody>
                {this.props.energyState.chartConfigs[
                  this.state.selected
                ].data.labels.map((month, index) => (
                  <tr>
                    <td>{month}</td>
                    <td sytle="{text-align: right}">
                      {formatNumber(
                        this.props.energyState.chartConfigs[this.state.selected]
                          .data.datasets[0].data[index]
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </Table>
          </Col>
        </Row>
      </ReportCard>
    );
  }
}

export default ChartReport;
