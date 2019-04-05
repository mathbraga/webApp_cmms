import React, { Component } from "react";
import ResultCard from "../../components/Cards/ResultCard";
import WidgetOneColumn from "../../components/Widgets/WidgetOneColumn";
import WidgetThreeColumns from "../../components/Widgets/WidgetThreeColumns";
import WidgetWithModalForAll from "../../components/Widgets/WidgetWithModalForAll";
import ReportListMeters from "../../components/Reports/ReportListMeters";
import { formatNumber } from "../../utils/formatText";
import { Row, Col } from "reactstrap";

class EnergyResultAM extends Component {
  render() {
    // Props: energyState, handleNewSearch

    // Initialize all variables
    // Loading images
    const imageEnergyMoney = require("../../assets/icons/money_energy.png");
    const imageEnergyPlug = require("../../assets/icons/money_energy.png");
    const imageEnergyWarning = require("../../assets/icons/money_energy.png");

    const { initialDate, meters, queryResponse } = this.props.energyState;
    let result = {
      unit: false,
      queryResponse: queryResponse[0].Items[0]
    };

    return (
      <ResultCard
        allUnits
        numOfUnits={meters.length}
        initialDate={initialDate}
        handleNewSearch={this.props.handleNewSearch}
      >
        <Row>
          <Col md="3">
            <WidgetOneColumn
              firstTitle={"Consumo Total"}
              firstValue={formatNumber(result.queryResponse.kwh, 0) + " kWh"}
              secondTitle={"Gasto Total"}
              secondValue={"R$ " + formatNumber(result.queryResponse.vbru, 2)}
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
          </Col>
          <Col md="3">
            <WidgetWithModalForAll
              data={""}
              title={"Diagnóstico"}
              buttonName={"Relatório"}
              image={imageEnergyWarning}
              marker={"erro(s)"}
            />
          </Col>
        </Row>
        <Row>
          <Col md="12">
            <ReportListMeters meters={this.props.energyState.meters} />
          </Col>
        </Row>
      </ResultCard>
    );
  }
}

export default EnergyResultAM;
