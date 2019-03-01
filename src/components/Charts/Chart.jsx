import React, { Component } from 'react';
import { Line } from 'react-chartjs-2';
import { Card, CardBody, CardHeader } from 'reactstrap';
import { CustomTooltips } from '@coreui/coreui-plugin-chartjs-custom-tooltips';

// const line = {
//   labels: ['January', 'February', 'March', 'April', 'May', 'June', 'July'],
//   datasets: [
//     {
//       label: 'My First dataset',
//       fill: false,
//       lineTension: 0.1,
//       backgroundColor: 'rgba(75,192,192,0.4)',
//       borderColor: 'rgba(75,192,192,1)',
//       borderCapStyle: 'butt',
//       borderDash: [],
//       borderDashOffset: 0.0,
//       borderJoinStyle: 'miter',
//       pointBorderColor: 'rgba(75,192,192,1)',
//       pointBackgroundColor: '#fff',
//       pointBorderWidth: 1,
//       pointHoverRadius: 5,
//       pointHoverBackgroundColor: 'rgba(75,192,192,1)',
//       pointHoverBorderColor: 'rgba(220,220,220,1)',
//       pointHoverBorderWidth: 2,
//       pointRadius: 1,
//       pointHitRadius: 10,
//       data: [65, 59, 80, 81, 56, 55, 40],
//     },
//   ],
// };


// const options = {
//   tooltips: {
//     enabled: false,
//     custom: CustomTooltips
//   },
//   maintainAspectRatio: false
// }

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