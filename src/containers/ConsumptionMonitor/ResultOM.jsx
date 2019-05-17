import React, { Component } from "react";
import { Row, Col } from "reactstrap";
import ResultCard from "../../components/Cards/ResultCard";
import WidgetOneColumn from "../../components/Widgets/WidgetOneColumn";
import WidgetThreeColumns from "../../components/Widgets/WidgetThreeColumns";
import WidgetWithModal from "../../components/Widgets/WidgetWithModal";
import ReportOneUnit from "../../components/Reports/ReportOneUnit";
import ReportInfo from "../../components/Reports/ReportInfo";
import ReportCalculations from "../../components/Reports/ReportCalculations";
import { transformDateString } from "../../utils/consumptionMonitor/transformDateString";
import formatNumber from "../../utils/consumptionMonitor/formatText";

class ResultOM extends Component {
  render() {

    const {
      initialDate,
      finalDate,
      oneMonth,
      meters,
      chosenMeter,
      meterType,
      resultObject
    } = this.props.consumptionState;
    // let resultType = "";
    // switch(this.props.meterType){
    //   case("1") : resultType = "energy";break;
    //   case("2") : resultType = "water";break;
    // }

    // Props: consumptionState, handleNewSearch

    // Initialize all variables
    // Loading images
    const imageEnergyMoney = require("../../assets/icons" + resultObject.image1);
    const imageEnergyPlug = require("../../assets/icons" + resultObject.image2);
    const imageEnergyWarning = require("../../assets/icons" + resultObject.image3);

    
    // let result = {
    //   unit: false,
    //   queryResponse: this.props.consumptionState.queryResponse[0].Items[0]
    // };
    // // Getting the right unit
    // meters.forEach(item => {
    //   if((parseInt(item.med.N) + 100*parseInt(item.tipomed.N)) === parseInt(chosenMeter)){
    //     result.unit = item;
    //   }
    // });
    // const dateString = transformDateString(result.queryResponse.aamm);

    // if(meterType === "1"){
      // Use 0 when "modalidade convencional"
      // Use 1 when "modalidade verde"
      // Use 2 when "modalidade azul"
      // const threeColumnValues = {
      //   0: {
      //     titles: [
      //       "Total",
      //       "CIP",
      //       "Tributos",
      //       "ICMS",
      //       "Multas/Juros",
      //       "Compensação"
      //     ],
      //     values: [
      //       "R$ " + formatNumber(result.queryResponse.vbru, 2),
      //       "R$ " + formatNumber(result.queryResponse.cip, 2),
      //       "R$ " + formatNumber(result.queryResponse.trib, 2),
      //       "R$ " + formatNumber(result.queryResponse.icms, 2),
      //       "R$ " + formatNumber(result.queryResponse.jma, 2),
      //       "R$ " + formatNumber(result.queryResponse.desc, 2)
      //     ]
      //   },
      //   1: {
      //     titles: [
      //       "Demanda FP",
      //       "Demanda P",
      //       "Contrato FP",
      //       "Contrato P",
      //       "Faturado FP",
      //       "Faturado P"
      //     ],
      //     values: [
      //       formatNumber(result.queryResponse.dmf, 0) + " kW",
      //       formatNumber(result.queryResponse.dmp, 0) + " kW",
      //       formatNumber(result.queryResponse.dcf, 0) + " kW",
      //       formatNumber(result.queryResponse.dcp, 0) + " kW",
      //       formatNumber(result.queryResponse.dff, 0) + " kW",
      //       formatNumber(result.queryResponse.dfp, 0) + " kW"
      //     ]
      //   },
      //   2: {
      //     titles: [
      //       "Demanda FP",
      //       "Demanda P",
      //       "Contrato FP",
      //       "Contrato P",
      //       "Faturado FP",
      //       "Faturado P"
      //     ],
      //     values: [
      //       formatNumber(result.queryResponse.dmf, 0) + " kW",
      //       formatNumber(result.queryResponse.dmp, 0) + " kW",
      //       formatNumber(result.queryResponse.dcf, 0) + " kW",
      //       formatNumber(result.queryResponse.dcp, 0) + " kW",
      //       formatNumber(result.queryResponse.dff, 0) + " kW",
      //       formatNumber(result.queryResponse.dfp, 0) + " kW"
      //     ]
      //   }
      // };

      // const typeText = {
      //   0: "Convencional",
      //   1: "Horária - Verde",
      //   2: "Horária - Azul"
      // };
    // }

    return (
      <ResultCard
        unitNumber={resultObject.unit.id.S}
        unitName={resultObject.unit.nome.S}
        initialDate={initialDate}
        finalDate={finalDate}
        oneMonth={oneMonth}
        typeOfUnit={resultObject.typeText[resultObject.queryResponse.tipo]}
        handleNewSearch={this.props.handleNewSearch}
      >
        <Row>
          <Col xs="12" sm="6" xl="3" className="order-xl-1 order-sm-1">
            <WidgetOneColumn
              firstTitle={"Consumo"}
              firstValue={formatNumber(resultObject.queryResponse.kwh, 0) + " kWh"}
              secondTitle={"Valor bruto"}
              secondValue={"R$ " + formatNumber(resultObject.queryResponse.vbru, 2)}
              image={imageEnergyMoney}
            />
          </Col>
          <Col xs="12" sm="12" xl="6" className="order-xl-2 order-sm-3">
            <WidgetThreeColumns
              titles={resultObject.threeColumnValues[resultObject.queryResponse.tipo].titles}
              values={resultObject.threeColumnValues[resultObject.queryResponse.tipo].values}
              image={imageEnergyPlug}
            />
          </Col>
          <Col xs="12" sm="6" xl="3" className="order-xl-3 order-sm-2">
            <WidgetWithModal
              chosenMeter={chosenMeter}
              unitNumber={resultObject.unit.id.S}
              unitName={resultObject.unit.nome.S}
              initialDate={initialDate}
              finalDate={finalDate}
              typeOfUnit={resultObject.typeText[resultObject.queryResponse.tipo]}
              data={resultObject}
              title={"Diagnóstico"}
              buttonName={"Ver relatório"}
              image={imageEnergyWarning}
              oneMonth={true}
            />
          </Col>
        </Row>
        <Row>
          <Col md="6">
            <ReportInfo data={resultObject.unit} date={resultObject.dateString} meterType={meterType} rowNamesInfo={resultObject.rowNamesInfo}/>
          </Col>
          <Col md="6">
            <ReportCalculations
              dbObject={this.props.consumptionState.dbObject}
              consumer={this.props.consumptionState.chosenMeter}
              dateString={resultObject.dateString}
              data={resultObject.queryResponse}
              demandContract={resultObject.unit}
              type={resultObject.queryResponse.tipo}
            />
          </Col>
        </Row>
        <Row>
          <Col>
            <ReportOneUnit
              data={resultObject.queryResponse}
              dateString={resultObject.dateString}
              dbObject={this.props.consumptionState.dbObject}
              tableName={this.props.consumptionState.tableName}
              consumer={this.props.consumptionState.chosenMeter}
              date={resultObject.queryResponse.aamm}
              meterType={meterType}
              rowNamesBill={resultObject.rowNamesBill}
            />
          </Col>
        </Row>
      </ResultCard>
    );
  }
}

export default ResultOM;
