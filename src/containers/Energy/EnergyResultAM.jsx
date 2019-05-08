import React, { Component } from "react";
import { Row, Col } from "reactstrap";
import ResultCard from "../../components/Cards/ResultCard";
import WidgetWithModal from "../../components/Widgets/WidgetWithModal";
import WidgetOneColumn from "../../components/Widgets/WidgetOneColumn";
import WidgetThreeColumns from "../../components/Widgets/WidgetThreeColumns";
import ReportListMeters from "../../components/Reports/ReportListMeters";
import formatNumber from "../../utils/energy/formatText";

class EnergyResultAM extends Component {
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
      chosenMeter,
      nonEmptyMeters,
      queryResponseAll
    } = this.props.energyState;
    let result = {
      unit: false,
      queryResponse: this.props.energyState.queryResponse[0].Items[0]
    };
    // Getting the right unit
    meters.forEach(item => {
      if (parseInt(item.med.N) + 100 == chosenMeter) result.unit = item;
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
          <Col xs="12" sm="6" xl="3" className="order-xl-1 order-sm-1">
            <WidgetOneColumn
              firstTitle={"Consumo"}
              firstValue={formatNumber(result.queryResponse.kwh, 0) + " kWh"}
              secondTitle={"Gasto"}
              secondValue={"R$ " + formatNumber(result.queryResponse.vbru, 2)}
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
                formatNumber(result.queryResponse.dms, 0) + " kW",
                "R$ " +
                  formatNumber(
                    result.queryResponse.vudf + result.queryResponse.vudp,
                    0
                  ),
                "R$ " + formatNumber(result.queryResponse.desc, 2),
                "R$ " + formatNumber(result.queryResponse.jma, 2),
                "R$ " +
                  formatNumber(
                    result.queryResponse.verexf + result.queryResponse.verexp,
                    2
                  ),
                formatNumber(
                  result.queryResponse.uferf + result.queryResponse.uferp,
                  0
                )
              ]}
              image={imageEnergyPlug}
            />
          </Col>{" "}
          <Col xs="12" sm="6" xl="3" className="order-xl-3 order-sm-2">
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
          </Col>
        </Row>

        <Row>
          <Col>
            <ReportListMeters
              meters={this.props.energyState.meters}
              nonEmptyMeters={this.props.energyState.nonEmptyMeters}
              resultType="energy"
            />
          </Col>
        </Row>
      </ResultCard>
    );
  }
}

export default EnergyResultAM;
