import React, { Component, Suspense } from "react";
import FormDates from "../../components/Forms/FormDates";
import Chart from "../../components/Charts/Chart";
import SimpleTable from "../../components/Tables/SimpleTable";
import { CardColumns, CardGroup, Col, Row } from "reactstrap";
import { CustomTooltips } from '@coreui/coreui-plugin-chartjs-custom-tooltips';

const data = {
  labels: ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'],
  datasets: [
    {
      label: 'kWh (2019)',
      fill: false,
      lineTension: 0.1,
      backgroundColor: 'rgba(75,192,192,0.4)',
      borderColor: 'rgba(75,192,192,1)',
      borderCapStyle: 'butt',
      borderDash: [],
      borderDashOffset: 0.0,
      borderJoinStyle: 'miter',
      pointBorderColor: 'rgba(75,192,192,1)',
      pointBackgroundColor: '#fff',
      pointBorderWidth: 1,
      pointHoverRadius: 5,
      pointHoverBackgroundColor: 'rgba(75,192,192,1)',
      pointHoverBorderColor: 'rgba(220,220,220,1)',
      pointHoverBorderWidth: 2,
      pointRadius: 1,
      pointHitRadius: 10,
      data: [1674268, 1766612, 1686418,	1807377,	1692058,	1513058,	1439933,	1426193,	1543408,	1555367,	1764463],
    },
  ],
};

const options = {
  tooltips: {
    enabled: false,
    custom: CustomTooltips
  },
  maintainAspectRatio: false
}

class Energy extends Component {

  constructor(props){
    super(props);
    this.state = {
      data: data,
      options: options
    };
  }

  render() {
    return(

      <div>
        
        <div>

          <FormDates />
          
        </div>

        <div>

          <CardColumns className="cols-2">

            <div>

              <Chart data={this.state.data} options={this.state.options}/>

              <SimpleTable />

            </div>
                                    
          </CardColumns>

        </div>

      </div>

    );
  }
}

export default Energy;
