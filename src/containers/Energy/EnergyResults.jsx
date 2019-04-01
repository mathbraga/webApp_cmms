import React, { Component } from "react";
import { Card, CardHeader, CardBody, Row, Col, Button } from "reactstrap";
import EnergyResultOM from "./EnergyResultOM";
import EnergyResultOP from "./EnergyResultOP";
import EnergyResultAM from "./EnergyResultAM";
import EnergyResultAP from "./EnergyResultAP";

class EnergyResults extends Component {
  render() {
    return (
      <React.Fragment>
        {this.props.energyState.oneMonth &&
          this.props.energyState.chosenMeter !== "199" && (
            <EnergyResultOM
              energyState={this.props.energyState}
              handleNewSearch={this.props.handleClick}
            />
          )}
        {!this.props.energyState.oneMonth &&
          this.props.energyState.chosenMeter !== "199" && (
            <EnergyResultOP
              energyState={this.props.energyState}
              handleNewSearch={this.props.handleClick}
            />
          )}
        {this.props.energyState.oneMonth &&
          this.props.energyState.chosenMeter === "199" && (
            <EnergyResultAM
              energyState={this.props.energyState}
              handleNewSearch={this.props.handleClick}
            />
          )}
        {!this.props.energyState.oneMonth &&
          this.props.energyState.chosenMeter === "199" && (
            <EnergyResultAP
              energyState={this.props.energyState}
              handleNewSearch={this.props.handleClick}
            />
          )}
      </React.Fragment>
    );
  }
}

export default EnergyResults;
