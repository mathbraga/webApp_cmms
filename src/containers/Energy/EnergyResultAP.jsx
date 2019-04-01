import React, { Component } from "react";
import ResultCard from "../../components/Cards/ResultCard";

class EnergyResultAP extends Component {
  render() {
    // Initialize all Variables
    const { meters, initialDate, finalDate } = this.props.energyState;

    return (
      <ResultCard
        allUnits
        numOfUnits={meters.length}
        initialDate={initialDate}
        endDate={finalDate}
        handleNewSearch={this.props.handleNewSearch}
      >
        <h1>Energy Result for All Units and Period!!!</h1>
      </ResultCard>
    );
  }
}

export default EnergyResultAP;
