import React, { Component, Suspense } from "react";
import FormDates from "../../components/Forms/FormDates";
import Chart from "../../components/Charts/Chart";
import SimpleTable from "../../components/Tables/SimpleTable";
import { CardColumns } from "reactstrap";

class Water extends Component {
  render() {
    return(
      <div>
        
        <FormDates />
        
        <CardColumns className="cols-2">

          <Chart />

          <SimpleTable />

        </CardColumns>
      
      </div>
    );
  }
}

export default Water;
