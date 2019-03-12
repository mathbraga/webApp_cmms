import React, { Component, Suspense } from "react";
import FormDates from "../../components/Forms/FormDates";
import Chart from "../../components/Charts/Chart";
import SimpleTable from "../../components/Tables/SimpleTable";
import { CardColumns } from "reactstrap";
import { handleDates } from "../../utils/handleDates";

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
