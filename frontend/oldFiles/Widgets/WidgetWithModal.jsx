import React, { Component } from "react";
import { Card, CardBody, Col, Row, Button, Badge } from "reactstrap";
import ReportProblems from "../Reports/ReportProblems";

class WidgetWithModal extends Component {
  /*
   * Props:
   * - allUnits (boolean):
   * - oneMonth (boolean):
   * - chosenMeter (string): value comes from Energy state
   * - unitNumber (string): id attribute of selected meter
   * - unitName (name): nome attribute of selected meter
   * - initialDate (string):
   * - finalDate (string):
   * - typeOfUnit (number): tipo attribute of selected meter
   * - title (string): Title of this widget
   * - marker (string): Text that describes the errors found
   * - buttonName (string): Text that will be inserted in the button
   * - image (image object): Image that appears in 'xl' screens. Positioned in the right side of the widget
   * - data (array): Values retrieved by the query to the database
   */
  constructor(props) {
    super(props);
    this.state = {
      // numProblems: 0, // Number of problems (marker)
      // problems: false, // Object with identified problems
      modal: false // Handle the modal (open or closed)
    };
  }

  // componentDidMount() {
  //   // If we have a queryResponse, check for problems
  //   if(this.props.data.queryResponse && this.props.oneMonth){
  //     let result = checkProblems(this.props.data.queryResponse, this.props.chosenMeter, this.props.queryResponseAll);
  //     // Variable for the number of problems found
  //     let numProblems = 0;
  //     Object.keys(result).forEach(key => {
  //       if (result[key].problem === true) numProblems += 1;
  //     });
  //     this.setState({
  //       numProblems: numProblems,
  //       problems: result
  //     });
  //   }
  // }

  toggleModal = () => {
    this.setState({
      modal: !this.state.modal
    });
  };

  render() {

    const {
      allUnits,
      unitNumber,
      typeOfUnit,
      chosenMeter,
      initialDate,
      finalDate,
      className,
      problems,
      queryResponseAll,
      meters,
      rowNamesReportProblems,
      image,
      title,
      buttonName,
      oneMonth,
      numOfUnits,
      numProblems,
      unitName
    } = this.props;

    return (
      <Card className="widget-container">
        <CardBody className="widget-body">
          <Row className="widget-container-text">
            <Col xs="8" className="pr-0">
              <div
                style={{
                  display: "flex",
                  "justifyContent": "space-between",
                  "alignItems": "baseline"
                }}
              >
                <div className="widget-title text-truncate">
                  {title}
                </div>
                {oneMonth && (
                  <Badge color="danger">
                    {" "}{numProblems}{" "}problema(s){" "}
                  </Badge>
                )}
              </div>

              <div
                style={{
                  display: "flex",
                  flexFlow: "column",
                  justifyContent: "center",
                  height: "70%",
                  alignItems: "center"
                }}
              >
                {oneMonth ? (
                  <Button
                    outline
                    color="primary"
                    size="sm"
                    onClick={this.toggleModal}
                    style={{ width: "80%" }}
                  >
                    {buttonName}
                  </Button>
                ) : (
                  <p style={{ margin: "0" }}>Sem relatório</p>
                )}
                <ReportProblems
                  allUnits={allUnits}
                  oneMonth={oneMonth}
                  unitNumber={unitNumber}
                  unitName={unitName}
                  numOfUnits={numOfUnits}
                  typeOfUnit={typeOfUnit}
                  chosenMeter={chosenMeter}
                  initialDate={initialDate}
                  finalDate={finalDate}
                  isOpen={this.state.modal}
                  toggle={this.toggleModal}
                  className={"modal-lg " + className}
                  problems={problems}
                  queryResponseAll={queryResponseAll}
                  meters={meters}
                  rowNamesReportProblems={rowNamesReportProblems}
                />
              </div>
            </Col>
            <Col xs="4" className="widget-container-image">
              <img className="widget-image" src={image} alt="Widget Image"/>
            </Col>
          </Row>
        </CardBody>
      </Card>
    );
  }
}

export default WidgetWithModal;
