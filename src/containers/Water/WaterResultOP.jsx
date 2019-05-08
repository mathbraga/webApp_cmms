import React, { Component } from "react";
import { Row, Col } from "reactstrap";
import ResultCard from "../../components/Cards/ResultCard";
import ChartReport from "../../components/Charts/ChartReport";
import WidgetOneColumn from "../../components/Widgets/WidgetOneColumn";
import WidgetThreeColumns from "../../components/Widgets/WidgetThreeColumns";
import WidgetWithModal from "../../components/Widgets/WidgetWithModal";
import ReportInfoEnergy from "../../components/Reports/ReportInfoEnergy";
import ReportCalculationsEnergy from "../../components/Reports/ReportCalculationsEnergy";
import { transformDateString } from "../../utils/energy/transformDateString";
import formatNumber from "../../utils/energy/formatText";
import applyFuncToAttr from "../../utils/energy/objectOperations";

class WaterResultOP extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    // Initialize all variables
    const {
      meters,
      initialDate,
      finalDate,
      chosenMeter,
      dbObject
    } = this.props.waterState;

    let result = {
      unit: false,
      queryResponse: this.props.waterState.queryResponse[0].Items
    };
    // Getting the right unit
    meters.forEach(item => {
      if (parseInt(item.med.N) + 200 == chosenMeter) result.unit = item;
    });
    this.dateMax = applyFuncToAttr(result.queryResponse, "aamm", Math.max);
    const dateString = transformDateString(this.dateMax);

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
        unitNumber={result.unit.id.S}
        unitName={result.unit.nome.S}
        initialDate={initialDate}
        finalDate={finalDate}
        typeOfUnit="Medidor CAESB"
        handleNewSearch={this.props.handleNewSearch}
      >
        {/* <Row>
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
                "Dem. Máx.",
                "Dem. Mín.",
                "Cons. Máx.",
                "Cons. Mín.",
                "Erex",
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
        </Row> */}
        <Row>
          <Col md="12">
            <ReportInfoEnergy data={result.unit} date={dateString} resultType="water" />
          </Col>
          {/* <Col md="6">
            <ReportCalculationsEnergy
              dbObject={dbObject}
              consumer={chosenMeter}
              dateString={dateString}
              data={result.queryResponse}
              demandContract={result.unit}
              type={result.queryResponse[result.queryResponse.length - 1].tipo}
            />
          </Col> */}
        </Row>
        <Row>
          <Col>
            <ChartReport
              waterState={this.props.waterState}
              medName={result.unit.nome.S}
              itemsForChart={itemsForChart}
              chartConfigs={this.props.waterState.chartConfigs}
              tableName={this.props.waterState.tableName}
            />
          </Col>
        </Row>
      </ResultCard>
    );
  }
}

export default WaterResultOP;
