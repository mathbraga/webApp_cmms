import React, { Component } from 'react';
import { Line } from 'react-chartjs-2';
import { Card, CardBody, CardHeader, Row, Col, FormGroup, Input, Label } from 'reactstrap';

const yAxisDropdown = {
  basec: "Base de cálculo",
  cip: "Contribuição de iluminação pública - CIP",
  desc: "Compensações e/ou descontos",
  dff: "Demanda faturada - Fora de ponta",
  dfp: "Demanda faturada - Ponta",
  dmf: "Demanda medida - Fora de ponta",
  dmp: "Demanda medida - Ponta",
  erexf: "EREX - Fora de ponta",
  erexp: "EREX - Ponta",
  icms: "ICMS",
  jma: "Juros, multas e atualizações monetárias",
  kwh: "Consumo total",
  kwhf: "Consumo - Fora de ponta",
  kwhp: "Consumo - Ponta",
  trib: "Tributos federais",
  vbru: "Valor bruto",
  vdff: "Valor da demanda faturada - Fora de ponta",
  vdfp: "Valor da demanda faturada - Ponta",
  verexf: "Valor EREX - Fora de ponta",
  verexp: "Valor EREX - Ponta",
  vliq: "Valor líquido",
  vudf: "Valor da ultrapassagem de demanda - Fora de ponta",
  vudp: "Valor da ultrapassagem de demanda - Ponta"
};

class Chart extends Component {
  constructor(props){
    super(props);
    this.state = {
      selected: "vbru",
      chartConfig: {}
    };
  }

  componentDidMount(){
    this.setState({chartConfig: this.props.energyState.chartConfig});
  }

  onChangeYAxis = event => {
    let newChartConfig = {
      type: this.state.chartConfig.type,
      data: {
        labels: this.state.chartConfig.data.labels,
        datasets: [{
        label: '',
        backgroundColor: "rgb(0, 14, 38)",
        borderColor: "rgb(0, 14, 38)",
        data: this.state.chartConfig.answers[event.target.value]
      }],
        fill: false,

      },
      options: this.state.chartConfig.options,
      answers: this.state.chartConfig.answers
    }
    this.setState({
      selected: [event.target.value],
      chartConfig: newChartConfig
    });
  }

  render() {
    
    return (
      <div className="animated fadeIn">
        {/* <CardColumns className="cols-2"> */}
          <Card>
            <CardHeader>
              Gráfico de resultados
            </CardHeader>
            <CardBody>
              <Row>
                <Col sm={2}></Col>
                <Col sm={2}>
                  <Row>
                    <Input type="select" name="yAxis" id="yAxis" onChange={this.onChangeYAxis}>
                      {Object.keys(this.props.energyState.chartConfig.answers).map(key =>(
                        this.state.selected === key
                        ? (
                          <option
                            selected="selected"
                            value={key}
                          >{yAxisDropdown[key]}
                          </option>
                        )
                        : (
                          <option
                          value={key}
                          >{yAxisDropdown[key]}
                          </option>
                        )
                      ))}
                    </Input>
                  </Row>
                </Col>
                <Col sm={2}></Col>
              </Row>
                    
              <Row>
                <Col md={6}>
                  <Row className="chart-wrapper">
                    <Line data={this.state.chartConfig.data} options={this.state.chartConfig.options}/>
                  </Row>
                </Col>
              </Row>





                    {/* {Object.keys(this.props.energyState.chartConfig.answers).map(key => (
                      this.state.selected === key
                        ? (<FormGroup check option>
                            <Input inline
                              className="form-check-input"
                              type="radio"
                              key={key}
                              id={key}
                              name="yAxis"
                              value={key}
                              onChange={this.onChangeYAxis}
                              checked
                            >
                            </Input>
                            <Label check className="form-check-label">
                              {key}
                            </Label>
                          </FormGroup>)
                          : (<FormGroup check inline>
                            <Input inline
                              className="form-check-input"
                              type="radio"
                              key={key}
                              id={key}
                              name="yAxis"
                              value={key}
                              onChange={this.onChangeYAxis}
                            >
                            </Input>
                            <Label check className="form-check-label">
                              {key}
                            </Label>
                          </FormGroup>)
                        ))}
                    
                    
                    
                    
                    
                    
                    <Input
                      type="select"
                      name="selected"
                      id="selected"
                      onChange={this.onChangeYAxis}>
                    </Input>
                  </Row>
                  
                </Col>




                  <FormGroup row className="radio">
                    <Label>OPÇÕES</Label>
                      <div>
                        
                      </div>
                  </FormGroup>
                </Col>
              </Row> */}
            </CardBody>
          </Card>
        {/* </CardColumns> */}
      </div>
    );
  }
}

export default Chart;