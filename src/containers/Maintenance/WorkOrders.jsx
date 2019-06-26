import React, { Component } from "react";
import { fakeWorkOrders } from "./fakeWorkOrders";

class WorkOrders extends Component {
  render() {
    return (
      <React.Fragment>

          <Route
            render={routerProps => (
              <WorkOrdersTable
                {...routerProps}
                tableConfig={fakeWorkOrders.tableConfig}
                items={fakeWorkOrders.items}
              />
            )}
          />
        
      </React.Fragment>
    );
  }
}

export default WorkOrders;
