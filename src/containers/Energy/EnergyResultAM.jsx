import React, { Component } from "react";
import ResultCard from "../../components/Cards/ResultCard";

class EnergyResultAM extends Component {
  render() {
    // Initialize all variables
    const { meters, initialDate } = this.props.energyState;

    return (
      <ResultCard
        allUnits
        numOfUnits={meters.length}
        initialDate={initialDate}
        handleNewSearch={this.props.handleNewSearch}
      >
        <h1>Energy Result for All Units and One Month!!!</h1>
      </ResultCard>
    );
  }
}

export default EnergyResultAM;
