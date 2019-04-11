import React, { Component } from "react";
import { Card, CardHeader, CardBody, Row, Col, Input, Table } from "reactstrap";
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

    console.log("ChartReport:");
    console.log(this.props);
    console.log(dropdowItems);

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

      // <Card>
      //   <CardHeader>
      //     <Row>
      //       Ver resultados de:
      //       <Col md="4">
      //         <Input
      //           type="select"
      //           defaultValue="vbru"
      //           name="yAxis"
      //           id="yAxis"
      //           onChange={this.onChangeYAxis}
      //         >
      //           {Object.keys(this.props.energyState.chartConfigs).map(key => (
      //             <option value={key} key={key}>
      //               {
      //                 this.props.energyState.chartConfigs[key].options.title
      //                   .text
      //               }
      //             </option>
      //           ))}
      //         </Input>
      //       </Col>
      //     </Row>
      //   </CardHeader>
      //   <CardBody>
      //     <Row>
      //       <Col md="8">
      //         <Line
      //           data={
      //             this.props.energyState.chartConfigs[this.state.selected].data
      //           }
      //           options={
      //             this.props.energyState.chartConfigs[this.state.selected]
      //               .options
      //           }
      //           redraw={true}
      //         />
      //       </Col>

      //       <Col md="1" />

      //       <Col md="2">
      //         <Table responsive size="sm">
      //           <thead>
      //             <tr className="header-table">
      //               <th />
      //               {/* {Object.keys(this.props.chartConfigs).map(key => (
      //                   <th>{this.props.chartConfigs[key].options.title.text}</th>
      //                 ))} */}

      //               <th>
      //                 {this.props.energyState.chartConfigs[this.state.selected]
      //                   .options.title.text +
      //                   " (" +
      //                   this.props.energyState.chartConfigs[this.state.selected]
      //                     .options.scales.yAxes[0].scaleLabel.labelString +
      //                   ")"}
      //               </th>
      //             </tr>
      //           </thead>

      //           <tbody>
      //             {this.props.energyState.chartConfigs[
      //               this.state.selected
      //             ].data.labels.map((month, index) => (
      //               <tr>
      //                 <td>{month}</td>
      //                 {/* {Object.keys(this.props.chartConfigs).map(key => (
      //                     <td>
      //                       {this.props.chartConfigs[key].data.datasets[0].data[index]}
      //                     </td>
      //                   ))} */}

      //                 <td sytle="{text-align: right}">
      //                   {this.formatNumber(
      //                     this.props.energyState.chartConfigs[
      //                       this.state.selected
      //                     ].data.datasets[0].data[index]
      //                   )}
      //                 </td>
      //               </tr>
      //             ))}
      //           </tbody>
      //         </Table>
      //       </Col>

      //       <Col md="1" />
      //     </Row>
      //   </CardBody>
      // </Card>
    );
  }
}

export default ChartReport;
