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

class WaterResultOM extends Component {
  render() {
    // Props: waterState, handleNewSearch

    // Initialize all variables
    // Loading images
    // const imageEnergyMoney = require("../../assets/icons/money_energy.png");
    // const imageEnergyPlug = require("../../assets/icons/plug_energy.png");
    // const imageEnergyWarning = require("../../assets/icons/alert_icon.png");

    const {
      initialDate,
      finalDate,
      oneMonth,
      meters,
      chosenMeter
    } = this.props.waterState;
    let result = {
      unit: false,
      queryResponse: this.props.waterState.queryResponse[0].Items[0]
    };
    // Getting the right unit
    meters.forEach(item => {
      if (parseInt(item.med.N) + 200 == chosenMeter) result.unit = item;
    });
    const dateString = transformDateString(result.queryResponse.aamm);

    return (
      <ResultCard
        unitNumber={result.unit.id.S}
        unitName={result.unit.nome.S}
        initialDate={initialDate}
        finalDate={finalDate}
        oneMonth={oneMonth}
        typeOfUnit={"Medidor CAESB"}
        handleNewSearch={this.props.handleNewSearch}
      >
        {/* <Row>
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
        </Row> */}
        <Row>
          <Col md="12">
            <ReportInfoEnergy data={result.unit} date={dateString} resultType="water"/>
          </Col>
          {/* <Col md="6">
            <ReportCalculationsEnergy
              dbObject={this.props.energyState.dbObject}
              consumer={this.props.energyState.chosenMeter}
              dateString={dateString}
              data={result.queryResponse}
              demandContract={result.unit}
              type={result.queryResponse.tipo}
            />
          </Col> */}
        </Row>
        <Row>
          <Col>
            <ReportEnergyOneUnit
              data={result.queryResponse}
              dateString={dateString}
              dbObject={this.props.waterState.dbObject}
              consumer={this.props.waterState.chosenMeter}
              date={result.queryResponse.aamm}
            />
          </Col>
        </Row>
      </ResultCard>
    );
  }
}

export default WaterResultOM;
