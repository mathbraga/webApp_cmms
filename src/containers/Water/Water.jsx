import React, { Component, Suspense } from "react";
import FormDates from "../../components/Forms/FormDates";
import Chart from "../../components/Charts/Chart";
import SimpleTable from "../../components/Tables/SimpleTable";
import { CardColumns } from "reactstrap";
import { handleDates } from "../../utils/handleDates";

const waterUnits = [
  { key: 101, num: "005671-5", name: "SQS 309 BL D" },
  { key: 102, num: "005675-8", name: "SQS 309 BL C" },
  { key: 103, num: "005677-4", name: "SQS 309 BL G" },
  { key: 104, num: "008370-4", name: "Anexo I" },
  { key: 105, num: "008388-7", name: "Anexo II" },
  { key: 106, num: "008424-7", name: "Prodasen" },
  { key: 107, num: "008425-5", name: "Portaria SEGRAF" },
  { key: 108, num: "008459-1", name: "Garagem" },
  { key: 109, num: "031389-1", name: "SHIS QL 12 CJ 11 CS 03" },
  { key: 110, num: "335979-4", name: "Rampa do Congresso Nacional" },
  { key: 111, num: "345018-1", name: "Interlegis" },
  { key: 112, num: "361800-5", name: "Telefonia - Praça de Alimen." },
  { key: 113, num: "363549-1", name: "Telefonia - Reservatório BL 7" },
  { key: 199, num: "Todos", name: "Todas Un. Consumidoras" }
];

class Water extends Component {
  constructor(props) {
    super(props);
    this.state = {
      data: "",
      options: "",
      initialDate: "",
      finalDate: "",
      consumerUnit: ""
    };
  }

  handleChangeOnDates = handleDates.bind(this);

  render() {
    return (
      <div>
        <FormDates
          onChange={this.handleChangeOnDates}
          initialDate={this.state.initialDate}
          finalDate={this.state.finalDate}
          consumerUnits={waterUnits}
        />
        <CardColumns className="cols-2">
          <Chart />
          <SimpleTable />
        </CardColumns>
      </div>
    );
  }
}

export default Water;
