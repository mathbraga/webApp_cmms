import React, { Component } from "react";
import { Route, Switch } from "react-router-dom";
import WaterResultOM from "./WaterResultOM";
import WaterResultOP from "./WaterResultOP";
import WaterResultAM from "./WaterResultAM";
import WaterResultAP from "./WaterResultAP";

class WaterResults extends Component {
  render() {
    return (
      <>
      <Switch location={this.props.waterState.newLocation}>
        <Route
          path="/consumo/agua/resultados/OM"
          render={() => (
            <WaterResultOM
              waterState={this.props.waterState}
              handleNewSearch={this.props.handleClick}
            />
          )}
        />
        <Route
          path="/consumo/agua/resultados/OP"
          render={() => (
            <WaterResultOP
              waterState={this.props.waterState}
              handleNewSearch={this.props.handleClick}
            />
          )}
        />
        <Route
          path="/consumo/agua/resultados/AM"
          render={() => (
            <WaterResultAM
              waterState={this.props.waterState}
              handleNewSearch={this.props.handleClick}
            />
          )}
        />
        <Route
          path="/consumo/agua/resultados/AP"
          render={() => (
            <WaterResultAP
              waterState={this.props.waterState}
              handleNewSearch={this.props.handleClick}
            />
          )}
        />
      </Switch>
      </>
    );
  }
}

export default WaterResults;
