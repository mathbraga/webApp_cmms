import React, { Component, Suspense } from "react";
import FormDates from "../../components/Forms/FormDates";
import Chart from "../../components/Charts/Chart";
import SimpleTable from "../../components/Tables/SimpleTable";
import { CardColumns, CardGroup, Col, Row } from "reactstrap";
import { CustomTooltips } from "@coreui/coreui-plugin-chartjs-custom-tooltips";
import { handleDates } from "../../utils/handleDates";
import EnergyOneUnitDash from "./EnergyOneUnitDash";

const data = {
  labels: [
    "Jan",
    "Fev",
    "Mar",
    "Abr",
    "Mai",
    "Jun",
    "Jul",
    "Ago",
    "Set",
    "Out",
    "Nov",
    "Dez"
  ],
  datasets: [
    {
      label: "kWh (2019)",
      fill: false,
      lineTension: 0.1,
      backgroundColor: "rgba(75,192,192,0.4)",
      borderColor: "rgba(75,192,192,1)",
      borderCapStyle: "butt",
      borderDash: [],
      borderDashOffset: 0.0,
      borderJoinStyle: "miter",
      pointBorderColor: "rgba(75,192,192,1)",
      pointBackgroundColor: "#fff",
      pointBorderWidth: 1,
      pointHoverRadius: 5,
      pointHoverBackgroundColor: "rgba(75,192,192,1)",
      pointHoverBorderColor: "rgba(220,220,220,1)",
      pointHoverBorderWidth: 2,
      pointRadius: 1,
      pointHitRadius: 10,
      data: [
        1674268,
        1766612,
        1686418,
        1807377,
        1692058,
        1513058,
        1439933,
        1426193,
        1543408,
        1555367,
        1764463
      ]
    }
  ]
};

const options = {
  tooltips: {
    enabled: false,
    custom: CustomTooltips
  },
  maintainAspectRatio: false
};

const energyUnits = [
  { key: 101, num: "466453-1", name: "Setran" },
  { key: 102, num: "471550-0", name: "SQS 309 BL G - Zelador" },
  { key: 103, num: "471551-9", name: "SQS 309 BL G - Serviço" },
  { key: 104, num: "471552-7", name: "SQS 309 BL C - Zelador" },
  { key: 105, num: "471553-5", name: "SQS 309 BL C - Serviço" },
  { key: 106, num: "471554-3", name: "SQS 309 BL D - Zelador" },
  { key: 107, num: "471555-1", name: "SQS 309 BL D - Serviço" },
  { key: 108, num: "472913-7", name: "SHIS QL 12 CJ 11" },
  { key: 109, num: "491042-7", name: "Gráfico - SEEP" },
  { key: 110, num: "491747-2", name: "Anexo II - Garagem Med. 2" },
  { key: 111, num: "491750-2", name: "Anexo II - Garagem Med. 1" },
  { key: 112, num: "493169-6", name: "Ed. Principal e Anexo I" },
  { key: 113, num: "510213-8", name: "Torre Televisão" },
  { key: 114, num: "605120-0", name: "Unidades de Apoio" },
  { key: 115, num: "623849-1", name: "Ar-Condicionado Med. 1" },
  { key: 116, num: "675051-6", name: "Prodasen" },
  { key: 117, num: "856960-6", name: "SQS 309 BL C - Bomba Incêndio" },
  { key: 118, num: "856967-3", name: "SQS 309 BL D - Bomba Incêndio" },
  { key: 119, num: "856969-X", name: "SQS 309 BL G - Bomba Incêndio" },
  { key: 120, num: "966027-5", name: "Interlegis" },
  { key: 121, num: "1089425-X", name: "Posto Colorado/Antena" },
  { key: 122, num: "1100496-7", name: "Palácio do Comércio" },
  { key: 123, num: "1951042-X", name: "SCEN TR 03 LT 01" },
  { key: 199, num: "Todos", name: "Todas Un. Consumidoras" }
];

class Energy extends Component {
  constructor(props) {
    super(props);
    this.state = {
      data: data,
      options: options,
      initialDate: "",
      finalDate: "",
      consumerUnit: "101",
      oneMonth: false
    };
  }

  handleChangeOnDates = handleDates.bind(this);

  handleOneMonth = event => {
    this.setState({
      oneMonth: event.target.checked
    });
  };

  handleUnitChange = event => {
    this.setState({
      consumerUnit: event.target.value
    });
  };

  render() {
    return (
      <div>
        <div>
          <FormDates
            onChangeDate={this.handleChangeOnDates}
            initialDate={this.state.initialDate}
            finalDate={this.state.finalDate}
            oneMonth={this.state.oneMonth}
            consumerUnits={energyUnits}
            onChangeOneMonth={this.handleOneMonth}
            onUnitChange={this.handleUnitChange}
          />
        </div>
        <div>
          <EnergyOneUnitDash />
          {/* <CardColumns className="cols-2">
            <div>
              <Chart data={this.state.data} options={this.state.options} />
              <SimpleTable />
            </div>
          </CardColumns> */}
        </div>
      </div>
    );
  }
}

export default Energy;
