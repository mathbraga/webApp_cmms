import React, { Component } from "react";
import { Row, Col } from "reactstrap";
import ResultCard from "../../components/Cards/ResultCard";
import WidgetOneColumn from "../../components/Widgets/WidgetOneColumn";
import WidgetThreeColumns from "../../components/Widgets/WidgetThreeColumns";
import WidgetWithModal from "../../components/Widgets/WidgetWithModal";
import ReportEnergyOneUnit from "../../components/Reports/ReportEnergyOneUnit";
import ReportInfoEnergy from "../../components/Reports/ReportInfoEnergy";
import ReportCalculationsEnergy from "../../components/Reports/ReportCalculationsEnergy";
import { transformDateString } from "../../utils/energy/transformDateString";
import formatNumber from "../../utils/energy/formatText";

class EnergyResultOM extends Component {
  render() {
    // Props: energyState, handleNewSearch

    // Initialize all variables
    // Loading images
    const imageEnergyMoney = require("../../assets/icons/money_energy.png");
    const imageEnergyPlug = require("../../assets/icons/plug_energy.png");
    const imageEnergyWarning = require("../../assets/icons/alert_icon.png");

    const {
      initialDate,
      finalDate,
      oneMonth,
      meters,
      chosenMeter
    } = this.props.energyState;
    let result = {
      unit: false,
      queryResponse: this.props.energyState.queryResponse[0].Items[0]
    };
    // Getting the right unit
    meters.forEach(item => {
      if (parseInt(item.med.N) + 100 == chosenMeter) result.unit = item;
    });
    const dateString = transformDateString(result.queryResponse.aamm);

    // Use 0 when "modalidade convencional"
    // Use 1 when "modalidade verde"
    // Use 2 when "modalidade azul"
    const threeColumnValues = {
      0: {
        titles: [
          "Total",
          "CIP",
          "Tributos",
          "ICMS",
          "Multas/Juros",
          "Compensação"
        ],
        values: [
          "R$ " + formatNumber(result.queryResponse.vbru, 2),
          "R$ " + formatNumber(result.queryResponse.cip, 2),
          "R$ " + formatNumber(result.queryResponse.trib, 2),
          "R$ " + formatNumber(result.queryResponse.icms, 2),
          "R$ " + formatNumber(result.queryResponse.jma, 2),
          "R$ " + formatNumber(result.queryResponse.desc, 2)
        ]
      },
      1: {
        titles: [
          "Demanda FP",
          "Demanda P",
          "Contrato FP",
          "Contrato P",
          "Faturado FP",
          "Faturado P"
        ],
        values: [
          formatNumber(result.queryResponse.dmf, 0) + " kW",
          formatNumber(result.queryResponse.dmp, 0) + " kW",
          formatNumber(result.queryResponse.dcf, 0) + " kW",
          formatNumber(result.queryResponse.dcp, 0) + " kW",
          formatNumber(result.queryResponse.dff, 0) + " kW",
          formatNumber(result.queryResponse.dfp, 0) + " kW"
        ]
      },
      2: {
        titles: [
          "Demanda FP",
          "Demanda P",
          "Contrato FP",
          "Contrato P",
          "Faturado FP",
          "Faturado P"
        ],
        values: [
          formatNumber(result.queryResponse.dmf, 0) + " kW",
          formatNumber(result.queryResponse.dmp, 0) + " kW",
          formatNumber(result.queryResponse.dcf, 0) + " kW",
          formatNumber(result.queryResponse.dcp, 0) + " kW",
          formatNumber(result.queryResponse.dff, 0) + " kW",
          formatNumber(result.queryResponse.dfp, 0) + " kW"
        ]
      }
    };

    const typeText = {
      0: "Convencional",
      1: "Horária - Verde",
      2: "Horária - Azul"
    };

    return (
      <ResultCard
        unitNumber={result.unit.id.S}
        unitName={result.unit.nome.S}
        initialDate={initialDate}
        finalDate={finalDate}
        oneMonth={oneMonth}
        typeOfUnit={typeText[result.queryResponse.tipo]}
        handleNewSearch={this.props.handleNewSearch}
      >
        <Row>
          <Col xs="12" sm="6" xl="3" className="order-xl-1 order-sm-1">
            <WidgetOneColumn
              firstTitle={"Consumo"}
              firstValue={formatNumber(result.queryResponse.kwh, 0) + " kWh"}
              secondTitle={"Valor bruto"}
              secondValue={"R$ " + formatNumber(result.queryResponse.vbru, 2)}
              image={imageEnergyMoney}
            />
          </Col>
          <Col xs="12" sm="12" xl="6" className="order-xl-2 order-sm-3">
            <WidgetThreeColumns
              titles={threeColumnValues[result.queryResponse.tipo].titles}
              values={threeColumnValues[result.queryResponse.tipo].values}
              image={imageEnergyPlug}
            />
          </Col>
          <Col xs="12" sm="6" xl="3" className="order-xl-3 order-sm-2">
            <WidgetWithModal
              chosenMeter={chosenMeter}
              unitNumber={result.unit.id.S}
              unitName={result.unit.nome.S}
              initialDate={initialDate}
              finalDate={finalDate}
              typeOfUnit={typeText[result.queryResponse.tipo]}
              data={result}
              title={"Diagnóstico"}
              buttonName={"Ver relatório"}
              image={imageEnergyWarning}
              oneMonth={true}
            />
          </Col>
        </Row>
        <Row>
          <Col md="6">
            <ReportInfoEnergy data={result.unit} date={dateString} />
          </Col>
          <Col md="6">
            <ReportCalculationsEnergy
              dbObject={this.props.energyState.dbObject}
              consumer={this.props.energyState.chosenMeter}
              dateString={dateString}
              data={result.queryResponse}
              demandContract={result.unit}
              type={result.queryResponse.tipo}
            />
          </Col>
        </Row>
        <Row>
          <Col>
            <ReportEnergyOneUnit
              data={result.queryResponse}
              dateString={dateString}
              dbObject={this.props.energyState.dbObject}
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
