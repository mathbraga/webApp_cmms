import React, { Component } from "react";
import ResultCard from "../../components/Cards/ResultCard";
import WidgetWithModal from "../../components/Widgets/WidgetWithModal";
import WidgetOneColumn from "../../components/Widgets/WidgetOneColumn";
import WidgetThreeColumns from "../../components/Widgets/WidgetThreeColumns";
import WidgetWithModalForAll from "../../components/Widgets/WidgetWithModalForAll";
import ReportListMeters from "../../components/Reports/ReportListMeters";
import ChartReport from "../../components/Charts/ChartReport";
import { formatNumber } from "../../utils/formatText";
import { Row, Col } from "reactstrap";

class EnergyResultAP extends Component {
  render() {
    // Initialize all Variables
    const { meters, initialDate, finalDate, oneMonth, chosenMeter, queryResponse, chartConfigs } = this.props.energyState;
    const imageEnergyMoney = require("../../assets/icons/money_energy.png");
    const imageEnergyPlug = require("../../assets/icons/money_energy.png");
    const imageEnergyWarning = require("../../assets/icons/money_energy.png");

    let result = {
      unit: false,
      queryResponse: queryResponse[0].Items[0]
    };

    const totalValues = {};
    Object.keys(chartConfigs).forEach(key => {
      const values = chartConfigs[key].data.datasets[0].data;
      totalValues[key] = values.reduce(
        (previous, current) => (previous += current)
      );
    });

    let result = {
      unit: false,
      queryResponse: this.props.energyState.queryResponse[0].Items[0]
    };
    console.log("ResultAP:");
    console.log(this.props);
    console.log(totalValues);

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
        <Row>
          <Col md="3">
            <WidgetOneColumn
              firstTitle={"Consumo Total"}
              firstValue={formatNumber(totalValues.kwh, 0) + " kWh"}
              secondTitle={"Gasto Total"}
              secondValue={"R$ " + formatNumber(totalValues.vbru, 2)}
              image={imageEnergyMoney}
            />
          </Col>
          <Col md="6">
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
                formatNumber(totalValues.dms, 0) + " kW",
                "R$ " + formatNumber(totalValues.vudf + totalValues.vudp, 0),
                "R$ " + formatNumber(totalValues.desc, 2),
                "R$ " + formatNumber(totalValues.jma, 2),
                "R$ " +
                  formatNumber(totalValues.verexf + totalValues.verexp, 2),
                formatNumber(totalValues.uferf + totalValues.uferp, 0)
              ]}
              image={imageEnergyPlug}
            />
          </Col>
          <Col md="3">
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
            />
          </Col>
        </Row>
        <Row>
          <Col>
            <ChartReport
              energyState={this.props.energyState}
              medName={"23 medidores"}
            />
          </Col>
        </Row>
        <Row>
          <Col>
            <ReportListMeters meters={this.props.energyState.meters} />
          </Col>
        </Row>
      </ResultCard>
    );
  }
}

export default EnergyResultAP;
