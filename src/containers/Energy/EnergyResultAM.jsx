import React, { Component } from "react";
import ResultCard from "../../components/Cards/ResultCard";

class EnergyResultAM extends Component {
  render() {
    // Props: energyState, handleNewSearch

    // Initialize all variables
    // Loading images
    const imageEnergyMoney = require("../../assets/icons/money_energy.png");
    const imageEnergyPlug = require("../../assets/icons/money_energy.png");
    const imageEnergyWarning = require("../../assets/icons/money_energy.png");

    const { initialDate, meters } = this.props.energyState;

    console.log("ResultAM:");
    console.log(this.props);

    return (
      <ResultCard
        allUnits
        numOfUnits={meters.length}
        initialDate={initialDate}
        handleNewSearch={this.props.handleNewSearch}
      >
        {/* <Row>
          <Col md="3">
            <WidgetOneColumn
              firstTitle={"Consumo"}
              firstValue={formatNumber(result.queryResponse.kwh, 0) + " kWh"}
              secondTitle={"Gasto"}
              secondValue={"R$" + formatNumber(result.queryResponse.vbru, 2)}
              image={imageEnergyMoney}
            />
          </Col>
          <Col md="6">
            <WidgetThreeColumns
              titles={[
                "Demanda FP",
                "Demanda P",
                "Contrato FP",
                "Contrato P",
                "Faturado FP",
                "Faturado P"
              ]}
              values={[
                formatNumber(result.queryResponse.dmf, 0) + " kW",
                formatNumber(result.queryResponse.dmp, 0) + " kW",
                formatNumber(result.queryResponse.dcf, 0) + " kW",
                formatNumber(result.queryResponse.dcp, 0) + " kW",
                formatNumber(result.queryResponse.dff, 0) + " kW",
                formatNumber(result.queryResponse.dfp, 0) + " kW"
              ]}
              image={imageEnergyPlug}
            />
          </Col>
          <Col md="3">
            <WidgetWithModal
              data={result}
              title={"Diagnóstico"}
              buttonName={"Relatório"}
              image={imageEnergyWarning}
              marker={"erro(s)"}
            />
          </Col>
        </Row> */}
      </ResultCard>
    );
  }
}

export default EnergyResultAM;
