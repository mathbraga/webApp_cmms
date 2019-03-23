import React, { Component } from 'react';
import { Line } from 'react-chartjs-2';
import { Card, CardBody, CardHeader } from 'reactstrap';

class Chart extends Component {

  constructor(props){
    super(props);
  }

  render() {

    return (
      <div className="animated fadeIn">
        {/* <CardColumns className="cols-2"> */}
          <Card>
            <CardHeader>
              Gráfico de resultados
              <div className="card-header-actions">
                <a href="http://www.chartjs.org" className="card-header-action">
                  <small className="text-muted">docs</small>
                </a>
              </div>
            </CardHeader>
            <CardBody>
              <div className="chart-wrapper">
                <Line data={this.props.data} options={this.props.options}/> 
              </div>
            </CardBody>
          </Card>
        {/* </CardColumns> */}
      </div>
    );
  }
}

export default Chart;