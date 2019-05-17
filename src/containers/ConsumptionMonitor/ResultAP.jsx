import React, { Component } from "react";
import { Row, Col } from "reactstrap";
import ResultCard from "../../components/Cards/ResultCard";
import WidgetWithModal from "../../components/Widgets/WidgetWithModal";
import WidgetOneColumn from "../../components/Widgets/WidgetOneColumn";
import WidgetThreeColumns from "../../components/Widgets/WidgetThreeColumns";
import ReportListMeters from "../../components/Reports/ReportListMeters";
import ChartReport from "../../components/Charts/ChartReport";
import formatNumber from "../../utils/consumptionMonitor/formatText";

class ResultAP extends Component {
  render() {
    // Initialize all Variables
    const {
      meters,
      initialDate,
      finalDate,
      oneMonth,
      chosenMeter,
      queryResponse,
      chartConfigs,
      nonEmptyMeters,
      resultObject
    } = this.props.consumptionState;
    
    const imageEnergyMoney = require("../../assets/icons" + resultObject.image1);
    const imageEnergyPlug = require("../../assets/icons" + resultObject.image2);
    const imageEnergyWarning = require("../../assets/icons" + resultObject.image3);

    // let result = {
    //   unit: false,
    //   queryResponse: queryResponse[0].Items[0]
    // };

    // const totalValues = {};
    // Object.keys(chartConfigs).forEach(key => {
    //   const values = chartConfigs[key].data.datasets[0].data;
    //   totalValues[key] = values.reduce(
    //     (previous, current) => (previous += current)
    //   );
    // });

    // const itemsForChart = [
    //   "vbru",
    //   "vliq",
    //   "cip",
    //   "desc",
    //   "jma",
    //   "kwh",
    //   "kwhf",
    //   "kwhp",
    //   "dms",
    //   "vdff",
    //   "vdfp",
    //   "vudf",
    //   "vudp",
    //   "verexf",
    //   "verexp",
    //   "uferf",
    //   "uferp",
    //   "trib",
    //   "icms",
    //   "basec"
    // ];

    // const demMax = Math.max(...chartConfigs.dms.data.datasets[0].data);

    return (
      <ResultCard
        allUnits={true}
        oneMonth={oneMonth}
        unitNumber={"Todos medidores"}
        unitName={"Todos medidores"}
        numOfUnits={nonEmptyMeters.length}
        initialDate={initialDate}
        finalDate={finalDate}
        typeOfUnit={false}
        handleNewSearch={this.props.handleNewSearch}
      >
        <Row>
          <Col xs="12" sm="6" xl="3" className="order-xl-1 order-sm-1">
            <WidgetOneColumn
              firstTitle={"Consumo"}
              firstValue={formatNumber(resultObject.totalValues.kwh, 0) + " kWh"}
              secondTitle={"Gasto"}
              secondValue={"R$ " + formatNumber(resultObject.totalValues.vbru, 2)}
              image={imageEnergyMoney}
            />
          </Col>
          <Col xs="12" sm="12" xl="6" className="order-xl-2 order-sm-3">
            <WidgetThreeColumns
              titles={[
                "Demanda",
                "Ultrapass.",
                "Descontos",
                "Multas",
                "EREX",
                "UFER"
              ]}
              values={[
                formatNumber(resultObject.demMax, 0) + " kW",
                "R$ " + formatNumber(resultObject.totalValues.vudf + resultObject.totalValues.vudp, 2),
                "R$ " + formatNumber(resultObject.totalValues.desc, 2),
                "R$ " + formatNumber(resultObject.totalValues.jma, 2),
                "R$ " +
                  formatNumber(resultObject.totalValues.verexf + resultObject.totalValues.verexp, 2),
                formatNumber(resultObject.totalValues.uferf + resultObject.totalValues.uferp, 0)
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
              data={resultObject}
              title={"Diagnóstico"}
              buttonName={"Ver Relatório"}
              image={imageEnergyWarning}
            />
          </Col>
        </Row>
        <Row>
          <Col>
            <ChartReport
              consumptionState={this.props.consumptionState}
              medName={this.props.consumptionState.nonEmptyMeters.length.toString() + " medidores"}
              itemsForChart={resultObject.itemsForChart}
              chartConfigs={this.props.consumptionState.chartConfigs}
              tableName={this.props.consumptionState.tableName}
            />
          </Col>
        </Row>
        <Row>
          <Col>
            <ReportListMeters
              meters={meters}
              nonEmptyMeters={nonEmptyMeters}
            />
          </Col>
        </Row>
      </ResultCard>
    );
  }
}

export default ResultAP;
