import React, { Component } from "react";
import { Row, Col } from "reactstrap";
import ResultCard from "../../components/Cards/ResultCard";
import ChartReport from "../../components/Charts/ChartReport";
import WidgetOneColumn from "../../components/Widgets/WidgetOneColumn";
import WidgetThreeColumns from "../../components/Widgets/WidgetThreeColumns";
import WidgetWithModal from "../../components/Widgets/WidgetWithModal";
import ReportInfo from "../../components/Reports/ReportInfo";
import ReportCalculations from "../../components/Reports/ReportCalculations";
import { transformDateString } from "../../utils/consumptionMonitor/transformDateString";
import formatNumber from "../../utils/consumptionMonitor/formatText";
import applyFuncToAttr from "../../utils/consumptionMonitor/objectOperations";

class ResultOP extends Component {
  constructor(props) {
    super(props);
    const { Items } = props.consumptionState.queryResponse[0];
    this.totalKWh = applyFuncToAttr(Items, "kwh", (...values) =>
      values.reduce((previous, current) => (current += previous))
    );
    this.totalVbru = applyFuncToAttr(Items, "vbru", (...values) =>
      values.reduce((previous, current) => (current += previous))
    );
    this.demMax = Math.max(
      applyFuncToAttr(Items, "dmf", Math.max),
      applyFuncToAttr(Items, "dmp", Math.max)
    );

    this.demMinFP = applyFuncToAttr(Items, "dmf", Math.min);
    this.demMinP = applyFuncToAttr(Items, "dmp", Math.min);
    this.demMin = 0;
    if (this.demMinFP === 0) {
      this.demMin = this.demMinP;
    } else if (this.demMinP === 0) {
      this.demMin = this.demMinFP;
    } else this.demMin = Math.min(this.demMinFP, this.demMinP);

    this.consMax = applyFuncToAttr(Items, "kwh", Math.max);
    this.consMin = applyFuncToAttr(Items, "kwh", Math.min);
    this.erexSum = applyFuncToAttr(Items, "verexf", (...values) =>
      values.reduce((previous, current) => (current += previous))
    );
    this.erexSum += applyFuncToAttr(Items, "verexp", (...values) =>
      values.reduce((previous, current) => (current += previous))
    );
    this.multaSum = applyFuncToAttr(Items, "jma", (...values) =>
      values.reduce((previous, current) => (current += previous))
    );
    this.lastType = false;
    Items.forEach(item => {
      let lastDate = false;
      if (lastDate || item.aamm > lastDate) {
        lastDate = item.aamm;
        this.lastType = item.tipo;
      }
    });
  }

  render() {
    // Initialize all variables
    const {
      meters,
      initialDate,
      finalDate,
      chosenMeter,
      dbObject,
      meterType
    } = this.props.consumptionState;

    const imageEnergyMoney = require("../../assets/icons/money_energy.png");
    const imageEnergyPlug = require("../../assets/icons/plug_energy.png");
    const imageEnergyWarning = require("../../assets/icons/alert_icon.png");

    let result = {
      unit: false,
      queryResponse: this.props.consumptionState.queryResponse[0].Items
    };
    // Getting the right unit
    meters.forEach(item => {
      if (parseInt(item.med.N) + 100 == chosenMeter) result.unit = item;
    });
    this.dateMax = applyFuncToAttr(result.queryResponse, "aamm", Math.max);
    const dateString = transformDateString(this.dateMax);

    const typeText = {
      0: "Convencional",
      1: "Horária - Verde",
      2: "Horária - Azul"
    };

    const itemsForChart = [
      "vbru",
      "vliq",
      "cip",
      "desc",
      "jma",
      "kwh",
      "confat",
      "kwhf",
      "kwhp",
      "dms",
      "dmf",
      "dmp",
      "dcf",
      "dcp",
      "dff",
      "dfp",
      "vdff",
      "vdfp",
      "vudf",
      "vudp",
      "tipo",
      "verexf",
      "verexp",
      "uferf",
      "uferp",
      "trib",
      "icms",
      "basec"
    ];

    return (
      <ResultCard
        unitNumber={result.unit.id.S}
        unitName={result.unit.nome.S}
        initialDate={initialDate}
        finalDate={finalDate}
        typeOfUnit={typeText[this.lastType]}
        handleNewSearch={this.props.handleNewSearch}
      >
        <Row>
          <Col xs="12" sm="6" xl="3" className="order-xl-1 order-sm-1">
            <WidgetOneColumn
              firstTitle={"Consumo"}
              firstValue={formatNumber(this.totalKWh, 0) + " kWh"}
              secondTitle={"Gasto"}
              secondValue={"R$ " + formatNumber(this.totalVbru, 2)}
              image={imageEnergyMoney}
            />
          </Col>
          <Col xs="12" sm="12" xl="6" className="order-xl-2 order-sm-3">
            <WidgetThreeColumns
              titles={[
                "Dem. máx.",
                "Dem. mín.",
                "Cons. máx.",
                "Cons. mín.",
                "EREX",
                "Multas"
              ]}
              values={[
                formatNumber(this.demMax, 0) + " kW",
                formatNumber(this.demMin, 0) + " kW",
                formatNumber(this.consMax, 0) + " kWh",
                formatNumber(this.consMin, 0) + " kWh",
                "R$ " + formatNumber(this.erexSum, 2),
                "R$ " + formatNumber(this.multaSum, 2)
              ]}
              image={imageEnergyPlug}
            />
          </Col>
          <Col xs="12" sm="6" xl="3" className="order-xl-3 order-sm-2">
            <WidgetWithModal
              chosenMeter={chosenMeter}
              // unitNumber={result.unit.id.S}
              // unitName={result.unit.nome.S}
              initialDate={initialDate}
              finalDate={finalDate}
              // typeOfUnit={result.unit.modtar.S}
              data={result}
              title={"Diagnóstico"}
              buttonName={"Ver Relatório"}
              image={imageEnergyWarning}
            />
          </Col>
        </Row>
        <Row>
          <Col md="6">
            <ReportInfo data={result.unit} date={dateString} meterType={meterType}/>
          </Col>
          <Col md="6">
            <ReportCalculations
              dbObject={dbObject}
              consumer={chosenMeter}
              dateString={dateString}
              data={result.queryResponse}
              demandContract={result.unit}
              type={result.queryResponse[result.queryResponse.length - 1].tipo}
            />
          </Col>
        </Row>
        <Row>
          <Col>
            <ChartReport
              consumptionState={this.props.consumptionState}
              medName={result.unit.nome.S}
              itemsForChart={itemsForChart}
              chartConfigs={this.props.consumptionState.chartConfigs}
              tableName={this.props.consumptionState.tableName}
            />
          </Col>
        </Row>
      </ResultCard>
    );
  }
}

export default ResultOP;
