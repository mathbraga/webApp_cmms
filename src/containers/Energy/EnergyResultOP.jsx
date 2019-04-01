import React, { Component } from "react";
import ResultCard from "../../components/Cards/ResultCard";

class EnergyResultOP extends Component {
  render() {
    // Initialize all variables
    const {
      meters,
      initialDate,
      finalDate,
      chosenMeter
    } = this.props.energyState;
    let unit = {};
    meters.forEach(item => {
      if (parseInt(item.med.N) + 100 == chosenMeter) unit = item;
    });

    return (
      <ResultCard
        unitNumber={unit.idceb.S}
        unitName={unit.nome.S}
        initialDate={initialDate}
        endDate={finalDate}
        typeOfUnit={unit.modtar.S}
        handleNewSearch={this.props.handleNewSearch}
      >
        <h1>Energy Result for One Unit and Period!!!</h1>
      </ResultCard>
    );
  }
}

export default EnergyResultOP;
