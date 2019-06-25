import React, { Component } from "react";
import { Route } from "react-router-dom";
import WorkRequestsTable from "./WorkRequestsTable";
import { fakeRequests } from "./fakeRequests";

class WorkRequests extends Component {
  render() {
    return (
      <React.Fragment>

        <Route
          render={routerProps => (
            <WorkRequestsTable
              {...routerProps}
              items={fakeRequests}
            />
          )}
        />

      </React.Fragment>
    );
  }
}

export default WorkRequests;
