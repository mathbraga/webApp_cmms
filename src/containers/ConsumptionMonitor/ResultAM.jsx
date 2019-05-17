import React, { Component } from "react";
import { Row, Col } from "reactstrap";
import ResultCard from "../../components/Cards/ResultCard";
import WidgetWithModal from "../../components/Widgets/WidgetWithModal";
import WidgetOneColumn from "../../components/Widgets/WidgetOneColumn";
import WidgetThreeColumns from "../../components/Widgets/WidgetThreeColumns";
import ReportListMeters from "../../components/Reports/ReportListMeters";
import formatNumber from "../../utils/consumptionMonitor/formatText";

class ResultAM extends Component {
  render() {
    // Props: consumptionState, handleNewSearch

    // Initialize all variables
    // Loading images

    const {
      initialDate,
      finalDate,
      oneMonth,
      meters,
      chosenMeter,
      nonEmptyMeters,
      queryResponseAll,
      resultObject
    } = this.props.consumptionState;
    // let result = {
    //   unit: false,
    //   queryResponse: this.props.consumptionState.queryResponse[0].Items[0]
    // };
    // // Getting the right unit
    // meters.forEach(item => {
    //   if (parseInt(item.med.N) + 100 == chosenMeter) result.unit = item;
    // });
    // const dateString = transformDateString(result.queryResponse.aamm);

    const imageEnergyMoney = require("../../assets/icons" + resultObject.image1);
    const imageEnergyPlug = require("../../assets/icons" + resultObject.image2);
    const imageEnergyWarning = require("../../assets/icons" + resultObject.image3);

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
              firstValue={formatNumber(resultObject.queryResponse.kwh, 0) + " kWh"}
              secondTitle={"Gasto"}
              secondValue={"R$ " + formatNumber(resultObject.queryResponse.vbru, 2)}
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
                formatNumber(resultObject.queryResponse.dms, 0) + " kW",
                "R$ " +
                  formatNumber(
                    resultObject.queryResponse.vudf + resultObject.queryResponse.vudp,
                    0
                  ),
                "R$ " + formatNumber(resultObject.queryResponse.desc, 2),
                "R$ " + formatNumber(resultObject.queryResponse.jma, 2),
                "R$ " +
                  formatNumber(
                    resultObject.queryResponse.verexf + resultObject.queryResponse.verexp,
                    2
                  ),
                formatNumber(
                  resultObject.queryResponse.uferf + resultObject.queryResponse.uferp,
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
              chosenMeter={this.props.consumptionState.chosenMeter}
              initialDate={initialDate}
              finalDate={finalDate}
              data={resultObject}
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
              meters={this.props.consumptionState.meters}
              nonEmptyMeters={this.props.consumptionState.nonEmptyMeters}
            />
          </Col>
        </Row>
      </ResultCard>
    );
  }
}

export default ResultAM;
