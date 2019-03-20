import React, { Component, Suspense } from "react";
import FormDates from "../../components/Forms/FormDates";
import Chart from "../../components/Charts/Chart";
import SimpleTable from "../../components/Tables/SimpleTable";
import { CardColumns, CardGroup, Col, Row } from "reactstrap";
import { CustomTooltips } from "@coreui/coreui-plugin-chartjs-custom-tooltips";
import { handleDates } from "../../utils/handleDates";
import EnergyOneUnitDash from "./EnergyOneUnitDash";
import { dynamoInit } from "../../utils/dynamoinit";
import { queryEnergyTable } from "../../utils/queryEnergyTable";
import { energyinfoinit } from "../../utils/energyinfoinit";

const dynamo = dynamoInit();

const consumers = [
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
      meters: [],
      dynamo: dynamo,
      initialDate: "",
      finalDate: "",
      consumer: "101",
      oneMonth: false,
      queryResponse1: [],
      queryResponse2: [],
      error: false,
      showResult1: false,
      showResult2: false
    };
  }

  componentDidMount() {
    energyinfoinit(this.state.dynamo, "EnergyInfo").then(data => {
      this.setState({ meters: data });
    });
  }



  handleChangeOnDates = handleDates.bind(this);
  handleQuery = queryEnergyTable.bind(this);

  handleOneMonth = event => {
    this.setState({
      oneMonth: event.target.checked
    });
  };

  handleUnitChange = event => {
    this.setState({
      consumer: event.target.value
    });
  };

  showFormDates = event => {
    this.setState({
      showResult: false,
      initialDate: "",
      finalDate: "",
      consumer: "101",
      oneMonth: false
    });
  };

  render() {
    return (
      <div>
        <div>
          {this.state.showResult1 && this.state.showResult2
          ? <EnergyOneUnitDash handleClick={this.showFormDates} result1={this.state.queryResponse1} result2={this.state.queryResponse2}/>
          : (
            <FormDates
              onChangeDate={this.handleChangeOnDates}
              initialDate={this.state.initialDate}
              finalDate={this.state.finalDate}
              oneMonth={this.state.oneMonth}
              meters={this.state.meters}
              onChangeOneMonth={this.handleOneMonth}
              onUnitChange={this.handleUnitChange}
              onQuery={this.handleQuery}
            />
          )}
        </div>
      </div>
    );
  }
}

export default Energy;
