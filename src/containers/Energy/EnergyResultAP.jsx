import React, { Component } from "react";

class EnergyResultAP extends Component {
  constructor(props){
    super(props);
    this.state = {
      selected: "vbru"
    };
    this.onChangeYAxis = event => {
      this.setState({selected: event.target.value});
    }
    this.formatNumber = number => {
      return number.toLocaleString("pt-BR", { maximumFractionDigits: 2 });
    }
  }
  
  render() {
    return (
      <div>
        {/* <Card>
          <CardHeader>
            <Row>Ver resultados de:
              <Col md="4">
                <Input type="select" defaultValue="vbru" name="yAxis" id="yAxis" onChange={this.onChangeYAxis}>
                  {Object.keys(this.props.energyState.chartConfigs).map(key =>(
                    <option
                      value={key}
                      key={key}
                    >{this.props.energyState.chartConfigs[key].options.title.text}
                    </option>
                  ))}
                </Input>
              </Col>
            </Row>
          </CardHeader>
          <CardBody>
            <Row>
              <Col md="8">
                <Line
                  data={this.props.energyState.chartConfigs[this.state.selected].data}
                  options={this.props.energyState.chartConfigs[this.state.selected].options}
                  redraw={true}
                >
                </Line>
              </Col>
            
              <Col md="1"></Col>

              <Col md="2">
                <Table responsive size="sm">
                  <thead>
                    <tr className="header-table">
                      <th></th>
                      <th>
                        {this.props.energyState.chartConfigs[this.state.selected].options.title.text + " (" +
                        this.props.energyState.chartConfigs[this.state.selected].options.scales.yAxes[0].scaleLabel.labelString + ")"}
                      </th>

                    </tr>
                  </thead>
              
                  <tbody>
                    {this.props.energyState.chartConfigs[this.state.selected].data.labels.map((month, index) => (
                      <tr>
                        <td>{month}</td>
                        <td sytle="{text-align: right}">
                          {this.formatNumber(this.props.energyState.chartConfigs[this.state.selected].data.datasets[0].data[index])}
                        </td>

                      </tr>
                    ))}
                  </tbody>
                </Table>
              </Col>

              <Col md="1"></Col>

            </Row>
          </CardBody>
          </Card> */}


          <h1>INSIDE ENERGY RESULT AP</h1>
      </div>
    );
  }
}

export default EnergyResultAP;