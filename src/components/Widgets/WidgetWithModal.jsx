import React, { Component } from "react";
import { Card, CardBody, Col, Row, Button, Badge } from "reactstrap";
import { checkProblems } from "../../utils/checkProblems";
import ReportProblems from "../Reports/ReportProblems";

class WidgetWithModal extends Component {
  /*
   * Props:
   * - allUnits (boolean):
   * - oneMonth (boolean):
   * - chosenMeter (string): value comes from Energy state
   * - unitNumber (string): idceb attribute of selected meter
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
      numProblems: 0, // Number of problems (marker)
      problems: false, // Object with identified problems
      modal: false // Handle the modal (open or closed)
    };
  }

  componentDidMount() {
    // If we have a queryResponse, check for problems
    const result =
      this.props.data.queryResponse &&
      checkProblems(this.props.data.queryResponse, this.props.chosenMeter);
    // Variable for the number of problems found
    let numProblems = 0;
    Object.keys(result).forEach(key => {
      if (result[key].problem === true) numProblems += 1;
    });
    this.setState({
      numProblems: numProblems,
      problems: result
    });
  }

  toggleModal = () => {
    this.setState({
      modal: !this.state.modal
    });
  };

  render() {
    return (
      <Card className="widget-container">
        <CardBody className="widget-body">
          <Row className="widget-container-text">

          {this.props.oneMonth
            ? (<div>
            <Col xl="8" lg="12">
              <div
                style={{
                  display: "flex",
                  "justify-content": "space-between",
                  "align-items": "baseline"
                }}
              >
                <div className="widget-title">{this.props.title}</div>
                <Badge color="danger">
                  {" "}
                  {this.state.numProblems}
                  {" "}
                  {this.props.marker}
                  {" "}
                </Badge>
              </div>

              <div
                style={{
                  display: "flex",
                  "flex-flow": "column",
                  "justify-content": "center",
                  height: "70%"
                }}
              >
                <Button
                  outline
                  color="primary"
                  size="sm"
                  onClick={this.toggleModal}
                >
                  {this.props.buttonName}
                </Button>
                <ReportProblems
                  allUnits={this.props.allUnits}
                  oneMonth={this.props.oneMonth}
                  unitNumber={this.props.unitNumber}
                  unitName={this.props.unitName}
                  numOfUnits={this.props.numOfUnits}
                  typeOfUnit={false}
                  chosenMeter={this.props.chosenMeter}
                  initialDate={this.props.initialDate}
                  finalDate={this.props.finalDate}
                  isOpen={this.state.modal}
                  toggle={this.toggleModal}
                  className={"modal-lg " + this.props.className}
                  problems={this.state.problems}
                />
              </div>
            </Col>
            <Col xl="4" className="d-none d-xl-block widget-container-image">
              <img className="widget-image" src={this.props.image} />
            </Col>
            </div>)
            : (
              <div>
                <Col xs="12">
                  <div
                  style={{
                    display: "flex",
                    "justify-content": "space-between",
                    "align-items": "baseline"
                  }}
                  >
                    <br/>
                    Não há diagnóstico para pesquisa de período.
                  </div>
                </Col>
                {/* <Col xl="4" className="d-none d-xl-block widget-container-image">
                  <img className="widget-image" src={this.props.image} />
                </Col> */}
              </div>
            )
          }
          </Row>
        </CardBody>
      </Card>
    );
  }
}

export default WidgetWithModal;
