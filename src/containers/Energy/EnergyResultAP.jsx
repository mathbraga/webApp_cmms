import React, { Component } from "react";
import ResultCard from "../../components/Cards/ResultCard";
import WidgetWithModal from "../../components/Widgets/WidgetWithModal";
import WidgetOneColumn from "../../components/Widgets/WidgetOneColumn";
import WidgetThreeColumns from "../../components/Widgets/WidgetThreeColumns";
import ReportListMeters from "../../components/Reports/ReportListMeters";
import ChartReport from "../../components/Charts/ChartReport";
import { formatNumber } from "../../utils/formatText";
import { Row, Col } from "reactstrap";

class EnergyResultAP extends Component {
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
      noEmpty
    } = this.props.energyState;
    const imageEnergyMoney = require("../../assets/icons/money_energy.png");
    const imageEnergyPlug = require("../../assets/icons/plug_energy.png");
    const imageEnergyWarning = require("../../assets/icons/alert_icon.png");

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

    const itemsForChart = [
      "vbru",
      "vliq",
      "cip",
      "desc",
      "jma",
      "kwh",
      "kwhf",
      "kwhp",
      "dms",
      "vdff",
      "vdfp",
      "vudf",
      "vudp",
      "verexf",
      "verexp",
      "uferf",
      "uferp",
      "trib",
      "icms",
      "basec"
    ];

    const demMax = Math.max(...chartConfigs.dms.data.datasets[0].data);

    return (
      <ResultCard
        allUnits={true}
        oneMonth={oneMonth}
        unitName={"Todos os medidores"}
        numOfUnits={noEmpty.length}
        initialDate={initialDate}
        finalDate={finalDate}
        typeOfUnit={false}
        handleNewSearch={this.props.handleNewSearch}
      >
        <Row>
          <Col xs="12" sm="6" xl="3" className="order-xl-1 order-sm-1">
            <WidgetOneColumn
              firstTitle={"Consumo"}
              firstValue={formatNumber(totalValues.kwh, 0) + " kWh"}
              secondTitle={"Gasto"}
              secondValue={"R$ " + formatNumber(totalValues.vbru, 2)}
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
                formatNumber(demMax, 0) + " kW",
                "R$ " + formatNumber(totalValues.vudf + totalValues.vudp, 2),
                "R$ " + formatNumber(totalValues.desc, 2),
                "R$ " + formatNumber(totalValues.jma, 2),
                "R$ " +
                  formatNumber(totalValues.verexf + totalValues.verexp, 2),
                formatNumber(totalValues.uferf + totalValues.uferp, 0)
              ]}
              image={imageEnergyPlug}
            />
          </Col>
          <Col xs="12" sm="6" xl="3" className="order-xl-3 order-sm-2">
            <WidgetWithModal
              chosenMeter={chosenMeter}
              // unitNumber={result.unit.idceb.S}
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
          <Col>
            <ChartReport
              energyState={this.props.energyState}
              medName={"23 medidores"}
              itemsForChart={itemsForChart}
            />
          </Col>
        </Row>
        <Row>
          <Col>
            <ReportListMeters meters={meters} noEmpty={noEmpty} />
          </Col>
        </Row>
      </ResultCard>
    );
  }
}

export default EnergyResultAP;
