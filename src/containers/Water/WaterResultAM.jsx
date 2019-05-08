import React, { Component } from "react";
import { Row, Col } from "reactstrap";
import ResultCard from "../../components/Cards/ResultCard";
import WidgetWithModal from "../../components/Widgets/WidgetWithModal";
import WidgetOneColumn from "../../components/Widgets/WidgetOneColumn";
import WidgetThreeColumns from "../../components/Widgets/WidgetThreeColumns";
import ReportListMeters from "../../components/Reports/ReportListMeters";
import formatNumber from "../../utils/energy/formatText";

class WaterResultAM extends Component {
  render() {
    // Props: waterState, handleNewSearch

    const imageEnergyPlug = require("../../assets/icons/plug_energy.png");

    const {
      initialDate,
      finalDate,
      oneMonth,
      meters,
      chosenMeter,
      nonEmptyMeters,
      queryResponseAll
    } = this.props.waterState;
    let result = {
      unit: false,
      queryResponse: this.props.waterState.queryResponse[0].Items[0]
    };
    // Getting the right unit
    meters.forEach(item => {
      if (parseInt(item.med.N) + 200 == chosenMeter) result.unit = item;
    });
    // const dateString = transformDateString(result.queryResponse.aamm);

    return (
      <ResultCard
        allUnits={true}
        oneMonth={oneMonth}
        unitNumber={false}
        unitName={"Todos os medidores"}
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
              firstValue={formatNumber(result.queryResponse.kwh, 0) + " kWh"}
              secondTitle={"Gasto"}
              secondValue={"R$ " + formatNumber(result.queryResponse.vbru, 2)}
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
                formatNumber(result.queryResponse.consf, 0) + " m³",
                "R$ " + formatNumber(result.queryResponse.vagu, 2),
                "R$ " + formatNumber(result.queryResponse.vesg, 2),
                "R$ " + formatNumber(result.queryResponse.cofins + result.queryResponse.csll + result.queryResponse.irpj + result.queryResponse.pasep, 2),
                "R$ " + formatNumber(result.queryResponse.adic, 2),
                "R$ " + formatNumber(result.queryResponse.subtotal)
              ]}
              image={imageEnergyPlug}
            />
          </Col>{" "}
          {/* <Col xs="12" sm="6" xl="3" className="order-xl-3 order-sm-2">
            <WidgetWithModal
              allUnits={true}
              oneMonth={oneMonth}
              unitNumber={false}
              unitName={"Todos os medidores"}
              numOfUnits={nonEmptyMeters.length}
              typeOfUnit={false}
              chosenMeter={this.props.energyState.chosenMeter}
              initialDate={initialDate}
              finalDate={finalDate}
              data={result}
              title={"Diagnóstico"}
              buttonName={"Ver relatório"}
              image={imageEnergyWarning}
              queryResponseAll={queryResponseAll}
              meters={meters}
            />
            </Col> */}
        </Row>

        <Row>
          <Col>
            <ReportListMeters
              meters={this.props.waterState.meters}
              nonEmptyMeters={this.props.waterState.nonEmptyMeters}
              resultType="water"
            />
          </Col>
        </Row>
      </ResultCard>
    );
  }
}

export default WaterResultAM;
