import React, { Component } from "react";
import { Row, Col } from "reactstrap";
import ResultCard from "../../components/Cards/ResultCard";
import WidgetWithModal from "../../components/Widgets/WidgetWithModal";
import WidgetOneColumn from "../../components/Widgets/WidgetOneColumn";
import WidgetThreeColumns from "../../components/Widgets/WidgetThreeColumns";
import ReportListMeters from "../../components/Reports/ReportListMeters";
import ChartReport from "../../components/Charts/ChartReport";
import formatNumber from "../../utils/energy/formatText";

class WaterResultAP extends Component {
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
      nonEmptyMeters
    } = this.props.waterState;
    const imageEnergyPlug = require("../../assets/icons/plug_energy.png");

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
      "adic",
      "cofins",
      "consf",
      "consm",
      "csll",
      "dif",
      "lan",
      "lat",
      "irpj",
      "pasep",
      "subtotal",
      "vagu",
      "vesg"
    ];

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
          {/* <Col xs="12" sm="6" xl="3" className="order-xl-1 order-sm-1">
            <WidgetOneColumn
              firstTitle={"Consumo"}
              firstValue={formatNumber(totalValues.kwh, 0) + " kWh"}
              secondTitle={"Gasto"}
              secondValue={"R$ " + formatNumber(totalValues.vbru, 2)}
              image={imageEnergyMoney}
            />
          </Col> */}
          <Col xs="12">
            <WidgetThreeColumns
              titles={[
                "Consumo faturado",
                "Tarifa (água)",
                "Tarifa (esgoto)",
                "Tributos",
                "Adicional",
                "Total"
              ]}
              values={[
                formatNumber(totalValues.consf, 2) + " m³",
                "R$ " + formatNumber(totalValues.vagu, 2),
                "R$ " + formatNumber(totalValues.vesg, 2),
                "R$ " + formatNumber(totalValues.cofins + totalValues.csll + totalValues.irpj + totalValues.pasep, 2),
                "R$ " + formatNumber(totalValues.adic, 2),
                "R$ " + formatNumber(totalValues.subtotal)
              ]}
              image={imageEnergyPlug}
            />
          </Col>
          {/* <Col xs="12" sm="6" xl="3" className="order-xl-3 order-sm-2">
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
          </Col> */}
        </Row>
        <Row>
          <Col>
            <ChartReport
              energyState={this.props.energyState}
              medName={"23 medidores"}
              itemsForChart={itemsForChart}
              chartConfigs={this.props.waterState.chartConfigs}
              tableName={this.props.waterState.tableName}
            />
          </Col>
        </Row>
        <Row>
          <Col>
            <ReportListMeters
              meters={meters}
              nonEmptyMeters={nonEmptyMeters}
              resultType="water"
            />
          </Col>
        </Row>
      </ResultCard>
    );
  }
}

export default WaterResultAP;
