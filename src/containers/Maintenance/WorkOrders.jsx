import React, { Component } from "react";
import { Route } from "react-router-dom";
import WorkOrdersTable from "./WorkOrdersTable";
import { fakeWorkOrders } from "./fakeWorkOrders";
import { dbTables } from "../../aws";
import initializeDynamoDB from "../../utils/consumptionMonitor/initializeDynamoDB";
import getWorkOrders from "../../utils/maintenance/getWorkOrders";

class WorkOrders extends Component {
  constructor(props){
    super(props);
    this.state = {
      workOrders: []
    }
  }

  componentDidMount(){
    const tableName = dbTables.maintenance.tableName;
    let dbObject = initializeDynamoDB(false);
    getWorkOrders(dbObject, tableName)
    .then(workOrders => {
      console.log(workOrders);
      this.setState({
        workOrders: workOrders
      })
    })
    .catch(() => {
      console.log("Houve um problema.");
    });
  }

  render() {
    return (
      <React.Fragment>

          <Route
            render={routerProps => (
              <WorkOrdersTable
                {...routerProps}
                tableConfig={fakeWorkOrders.tableConfig}
                items={this.state.workOrders}
              />
            )}
          />
        
      </React.Fragment>
    );
  }
}

export default WorkOrders;
