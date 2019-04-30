import React, { Component } from "react";
import { Bar } from "react-chartjs-2";

const data = {
  labels: ["Janeiro"],
  datasets: [
    {
      label: "2019",
      backgroundColor: "rgba(255,99,132,0.2)",
      borderColor: "rgba(255,99,132,1)",
      borderWidth: 1,
      hoverBackgroundColor: "rgba(255,99,132,0.4)",
      hoverBorderColor: "rgba(255,99,132,1)",
      data: [1200]
    },
    {
      label: "2018",
      backgroundColor: "rgba(255,99,132,0.2)",
      borderColor: "rgba(255,99,132,1)",
      borderWidth: 1,
      hoverBackgroundColor: "rgba(255,99,132,0.4)",
      hoverBorderColor: "rgba(255,99,132,1)",
      data: [1500]
    }
  ]
};

class DoubleBarChart extends Component {
  render() {
    return (
      <Bar
        data={data}
        width={200}
        height={150}
        options={{
          maintainAspectRatio: false,
          legend: {
            display: false
          },
          scales: {
            yAxes: [{ ticks: { max: 1600, min: 1000, stepSize: 200 } }]
          }
        }}
      />
    );
  }
}

export default DoubleBarChart;
