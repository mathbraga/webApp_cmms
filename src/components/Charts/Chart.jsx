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
    };

    this.onChangeYAxis = event => {
      this.setState({selected: event.target.value});
    }
  }

  render() {
    
    return (
      <div className="animated fadeIn">
          <Card>
            <CardHeader>
              Gráfico de resultados
            </CardHeader>
            <CardBody>
              <Row>
                <Col sm={2}></Col>
                <Col sm={2}>
                  <Row>

                    <Input type="select" defaultValue="vbru" name="yAxis" id="yAxis" onChange={this.onChangeYAxis}>
                      {Object.keys(yAxisDropdown).map(key =>(
                        <option
                          value={key}
                          key={key}
                        >{yAxisDropdown[key]}
                        </option>
                      ))}
                    </Input>

                  </Row>
                </Col>
                <Col sm={2}></Col>
              </Row>
                    
              <Row>
                <Col md={6}>
                  <Row className="chart-wrapper">
                    <Line data={this.props.chartConfigs[this.state.selected].data} options={this.props.chartConfigs[this.state.selected].options}/>
                  </Row>
                </Col>
              </Row>

            </CardBody>
          </Card>
      </div>
    );
  }
}

export default Chart;