import React, { Component } from "react";
import { Row, Col } from "reactstrap";
import ResultCard from "../../components/Cards/ResultCard";
// import WidgetWithModal from "../../components/Widgets/WidgetWithModal";
import WidgetOneColumn from "../../components/Widgets/WidgetOneColumn";
import WidgetThreeColumns from "../../components/Widgets/WidgetThreeColumns";
// import ReportListMeters from "../../components/Reports/ReportListMeters";
import ChartReport from "../../components/Charts/ChartReport";

class ResultAPwater extends Component {
  render() {

    const {
      meters,
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
          <Col xs="12" sm="6" className="order-xl-1 order-sm-1">
            <WidgetOneColumn
              firstTitle={resultObject.widgetOneColumnFirstTitle}
              firstValue={resultObject.widgetOneColumnFirstValue}
              secondTitle={resultObject.widgetOneColumnSecondTitle}
              secondValue={resultObject.widgetOneColumnSecondValue}
              image={resultObject.imageWidgetOneColumn}
            />
          </Col>
          <Col xs="12" sm="6" className="order-xl-2 order-sm-2">
            <WidgetThreeColumns
              titles={resultObject.widgetThreeColumnsTitles}
              values={resultObject.widgetThreeColumnsValues}
              image={resultObject.imageWidgetThreeColumns}
            />
          </Col>
          {/* <Col xs="12" sm="6" xl="3" className="order-xl-3 order-sm-2">
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
          </Col> */}
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
        <Row>
          <Col>
            {/* <ReportListMeters
              meters={meters}
              nonEmptyMeters={resultObject.nonEmptyMeters}
            /> */}
          </Col>
        </Row>
      </ResultCard>
    );
  }
}

export default ResultAPwater;
