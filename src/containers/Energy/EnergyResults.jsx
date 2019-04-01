import React, { Component } from "react";
import { Card, CardHeader, CardBody, Row, Col, Button } from "reactstrap";
import { Route, Switch } from "react-router-dom";
import EnergyResultOM from "./EnergyResultOM";
import EnergyResultOP from "./EnergyResultOP";
import EnergyResultAM from "./EnergyResultAM";
import EnergyResultAP from "./EnergyResultAP";

class EnergyResults extends Component {
  render() {
    return (
          <Switch location={this.props.energyState.newLocation}>
            <Route
              path="/consumo/energia/resultados/OM"
              render={() => (
                <EnergyResultOM energyState={this.props.energyState} handleNewSearch={this.props.handleClick}/>
              )}
            />
            <Route
              path="/consumo/energia/resultados/OP"
              render={() => (
                <EnergyResultOP energyState={this.props.energyState} handleNewSearch={this.props.handleClick}/>
              )}
            />
            <Route
              path="/consumo/energia/resultados/AM"
              render={() => (
                <EnergyResultAM energyState={this.props.energyState} handleNewSearch={this.props.handleClick}/>
              )}
            />
            <Route
              path="/consumo/energia/resultados/AP"
              render={() => (
                <EnergyResultAP energyState={this.props.energyState} handleNewSearch={this.props.handleClick}/>
              )}
            />
          </Switch>
    );
  }
}

export default EnergyResults;
