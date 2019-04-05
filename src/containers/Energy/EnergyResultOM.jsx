import React, { Component } from "react";
import ResultCard from "../../components/Cards/ResultCard";
import { Row, Col } from "reactstrap";
import WidgetOneColumn from "../../components/Widgets/WidgetOneColumn";
import WidgetThreeColumns from "../../components/Widgets/WidgetThreeColumns";
import WidgetWithModal from "../../components/Widgets/WidgetWithModal";
import ReportEnergyOneUnit from "../../components/Reports/ReportEnergyOneUnit";
import ReportInfoEnergy from "../../components/Reports/ReportInfoEnergy";
import ReportCalculationsEnergy from "../../components/Reports/ReportCalculationsEnergy";
import { transformDateString } from "../../utils/transformDateString";
import { formatNumber } from "../../utils/formatText";

class EnergyResultOM extends Component {
  render() {
    // Props: energyState, handleNewSearch

    // Initialize all variables
    // Loading images
    const imageEnergyMoney = require("../../assets/icons/money_energy.png");
    const imageEnergyPlug = require("../../assets/icons/money_energy.png");
    const imageEnergyWarning = require("../../assets/icons/money_energy.png");

    const { initialDate, meters, chosenMeter } = this.props.energyState;
    let result = {
      unit: false,
      queryResponse: this.props.energyState.queryResponse[0].Items[0]
    };
    // Getting the right unit
    meters.forEach(item => {
      if (parseInt(item.med.N) + 100 == chosenMeter) result.unit = item;
    });
    const dateString = transformDateString(result.queryResponse.aamm);

    return (
      <ResultCard
        unitNumber={result.unit.idceb.S}
        unitName={result.unit.nome.S}
        initialDate={initialDate}
        typeOfUnit={result.unit.modtar.S}
        handleNewSearch={this.props.handleNewSearch}
      >
        <Row>
          <Col xs="12" lg="3">
            <WidgetOneColumn
              firstTitle={"Consumo"}
              firstValue={formatNumber(result.queryResponse.kwh, 0) + " kWh"}
              secondTitle={"Valor bruto"}
              secondValue={"R$ " + formatNumber(result.queryResponse.vbru, 2)}
              image={imageEnergyMoney}
            />
          </Col>
          <Col xs="12" lg="6">
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
          <Col xs="12" lg="3">
            <WidgetWithModal
              data={result}
              title={"Diagnóstico:"}
              buttonName={"Ver detalhes"}
              image={imageEnergyWarning}
              marker={"problema(s)"}
            />
          </Col>
        </Row>
        <Row>
          <Col md="6">
            <ReportInfoEnergy data={result.unit} date={dateString} />
          </Col>
          <Col md="6">
            <ReportCalculationsEnergy
              dbObject={this.props.energyState.dynamo}
              consumer={this.props.energyState.chosenMeter}
              dateString={dateString}
              data={result.queryResponse}
              demandContract={result.unit}
            />
          </Col>
        </Row>
        <Row>
          <Col>
            <ReportEnergyOneUnit
              data={result.queryResponse}
              dateString={dateString}
              dbObject={this.props.energyState.dynamo}
              consumer={this.props.energyState.chosenMeter}
              date={result.queryResponse.aamm}
            />
          </Col>
        </Row>
      </ResultCard>
    );
  }
}

export default EnergyResultOM;
