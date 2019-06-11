import React, { Component } from "react";
import { Row, Col } from "reactstrap";
import ResultCard from "../../components/Cards/ResultCard";
import ChartReport from "../../components/Charts/ChartReport";
import WidgetOneColumn from "../../components/Widgets/WidgetOneColumn";
import WidgetThreeColumns from "../../components/Widgets/WidgetThreeColumns";
import WidgetWithModal from "../../components/Widgets/WidgetWithModal";
import ReportInfo from "../../components/Reports/ReportInfo";
import ReportCalculations from "../../components/Reports/ReportCalculations";

class ResultOP extends Component {
  render() {

    const {
      dbObject,
      tableName,
      oneMonth,
      chosenMeter,
      resultObject
    } = this.props.consumptionState;

    const {
      handleNewSearch
    } = this.props;

    return (
      <ResultCard
        unitNumber={resultObject.unitNumber}
        unitName={resultObject.unitName}
        initialDate={resultObject.initialDate}
        finalDate={resultObject.finalDate}
        typeOfUnit={resultObject.typeText}
        oneMonth={oneMonth}
        handleNewSearch={handleNewSearch}
        allUnits={resultObject.allUnits}
        numOfUnits={resultObject.numOfUnits}
      >
        <Row>
          <Col xs="12" sm="6" xl="3" className="order-xl-1 order-sm-1">
            <WidgetOneColumn
              firstTitle={resultObject.widgetOneColumnFirstTitle}
              firstValue={resultObject.widgetOneColumnFirstValue}
              secondTitle={resultObject.widgetOneColumnSecondTitle}
              secondValue={resultObject.widgetOneColumnSecondValue}
              image={resultObject.imageWidgetOneColumn}
            />
          </Col>
          <Col xs="12" sm="12" xl="6" className="order-xl-2 order-sm-3">
            <WidgetThreeColumns
              titles={resultObject.widgetThreeColumnsTitles}
              values={resultObject.widgetThreeColumnsValues}
              image={resultObject.imageWidgetThreeColumns}
            />
          </Col>
          <Col xs="12" sm="6" xl="3" className="order-xl-3 order-sm-2">
            <WidgetWithModal
              chosenMeter={chosenMeter}
              unitNumber={resultObject.unitNumber}
              unitName={resultObject.unitName}
              initialDate={resultObject.initialDate}
              finalDate={resultObject.finalDate}
              typeOfUnit={resultObject.typeText}
              title={resultObject.widgetWithModalTitle}
              buttonName={resultObject.widgetWithModalButtonName}
              image={resultObject.imageWidgetWithModal}
              oneMonth={oneMonth}
              numProblems={resultObject.numProblems}
              problems={resultObject.problems}
              rowNamesReportProblems={resultObject.rowNamesReportProblems}
              allUnits={resultObject.allUnits}
              numOfUnits={resultObject.numOfUnits}
            />
          </Col>
        </Row>
        <Row>
          <Col md="6">
            <ReportInfo
              unit={resultObject.unit}
              rowNamesInfo={resultObject.rowNamesInfo}
            />
          </Col>
          <Col md="6">
            <ReportCalculations
              dbObject={dbObject}
              tableName={tableName}
              consumer={chosenMeter}
              dateString={resultObject.dateString}
              data={resultObject.queryResponse}
              unit={resultObject.unit}
              type={resultObject.type}
            />
          </Col>
        </Row>
        <Row>
          <Col>
            <ChartReport
              unitName={resultObject.unitName}
              dropdownItems={resultObject.dropdownItems}
              chartConfigs={resultObject.chartConfigs}
              title={resultObject.chartReportTitle}
              titleColSize={resultObject.chartReportTitleColSize}
              subtitle={resultObject.chartSubtitle}
              subvalue={resultObject.chartSubvalue}
              selectedDefault={resultObject.selectedDefault}
            />
          </Col>
        </Row>
      </ResultCard>
    );
  }
}

export default ResultOP;
