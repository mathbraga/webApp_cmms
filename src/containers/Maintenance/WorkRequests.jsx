import React, { Component } from "react";
import { Route } from "react-router-dom";
import TableItems from "../../components/Tables/Table";
import WorkRequestsTable from "./WorkRequestsTable";
import { fakeWorkRequests } from "./fakeWorkRequests";

class WorkRequests extends Component {
  render() {
    return (
      <React.Fragment>

        <Route
          render={routerProps => (
            <WorkRequestsTable
              {...routerProps}
              tableConfig={fakeWorkRequests.tableConfig}
              items={fakeWorkRequests.items}
            />
            // <TableItems
            //   {...routerProps}
            //   tableConfig={fakeWorkRequests.tableConfig}
            //   items={fakeWorkRequests.items}
            // />
          )}
        />

      </React.Fragment>
    );
  }
}

export default WorkRequests;
