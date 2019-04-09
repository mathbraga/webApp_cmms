import React, { Component } from "react";
import ResultCard from "../../components/Cards/ResultCard";
import { transformDateString } from "../../utils/transformDateString";
import { Row, Col } from "reactstrap";
import WidgetWithModal from "../../components/Widgets/WidgetWithModal"

class EnergyResultAM extends Component {
  render() {
    // Props: energyState, handleNewSearch

    // Initialize all variables
    // Loading images
    const imageEnergyMoney = require("../../assets/icons/money_energy.png");
    const imageEnergyPlug = require("../../assets/icons/money_energy.png");
    const imageEnergyWarning = require("../../assets/icons/money_energy.png");

    const { initialDate, finalDate, oneMonth, meters, chosenMeter } = this.props.energyState;
    let result = {
      unit: false,
      queryResponse: this.props.energyState.queryResponse[0].Items[0]
    };
    // Getting the right unit
    meters.forEach(item => {
      if (parseInt(item.med.N) + 100 == chosenMeter) result.unit = item;
    });
    // const dateString = transformDateString(result.queryResponse.aamm);

    console.log("ResultAM:");
    console.log(this.props);

    return (
      <ResultCard
        allUnits={true}
        oneMonth={oneMonth}
        unitNumber={false}
        unitName={"Todos os medidores"}
        numOfUnits={meters.length}
        initialDate={initialDate}
        finalDate={finalDate}
        typeOfUnit={false}
        handleNewSearch={this.props.handleNewSearch}
      >
        <Row>
          {/* <Col md="3">
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
            </Col> */}
          <Col md="3">
            <WidgetWithModal
              allUnits={true}
              oneMonth={oneMonth}
              unitNumber={false}
              unitName={"Todos os medidores"}
              numOfUnits={meters.length}
              typeOfUnit={false}
              chosenMeter={this.props.energyState.chosenMeter}
              initialDate={initialDate}
              finalDate={finalDate}
              data={result}
              title={"Diagnóstico:"}
              buttonName={"Ver detalhes"}
              image={imageEnergyWarning}
              marker={"problema(s)"}
            />
          </Col>
        </Row>
      </ResultCard>
    );
  }
}

export default EnergyResultAM;
