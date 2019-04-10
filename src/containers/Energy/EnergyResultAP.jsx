import React, { Component } from "react";
import ResultCard from "../../components/Cards/ResultCard";
import WidgetWithModal from "../../components/Widgets/WidgetWithModal";

class EnergyResultAP extends Component {
  render() {
    // Initialize all Variables
    const { meters, initialDate, finalDate, oneMonth, chosenMeter } = this.props.energyState;
    const imageEnergyWarning = require("../../assets/icons/money_energy.png");

    let result = {
      unit: false,
      queryResponse: this.props.energyState.queryResponse[0].Items[0]
    };
    console.log("ResultAP:");
    console.log(this.props);

    return (
      <ResultCard
        allUnits={true}
        oneMonth={oneMonth}
        unitName={"Todos os medidores"}
        numOfUnits={meters.length}
        initialDate={initialDate}
        finalDate={finalDate}
        typeOfUnit={false}
        handleNewSearch={this.props.handleNewSearch}
      >
        <WidgetWithModal
        chosenMeter={chosenMeter}
        // unitNumber={result.unit.idceb.S}
        // unitName={result.unit.nome.S}
        initialDate={initialDate}
        finalDate={finalDate}
        // typeOfUnit={result.unit.modtar.S}
        data={result}
        title={"Não há diagnóstico para pesquisa de período"}
        buttonName={""}
        image={imageEnergyWarning}
        marker={""}
        >


        </WidgetWithModal>
      </ResultCard>
    );
  }
}

export default EnergyResultAP;
