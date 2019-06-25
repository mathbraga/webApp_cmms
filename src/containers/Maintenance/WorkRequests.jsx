import React, { Component } from "react";
import { Route } from "react-router-dom";
import WorkRequestsTable from "./WorkRequestsTable";

class WorkRequests extends Component {
  render() {
    return (
      <React.Fragment>

        <Route
          render={routerProps => (
            <WorkRequestsTable
              {...routerProps}
            />
          )}
        />

      </React.Fragment>
    );
  }
}

export default WorkRequests;
