import React, { Component } from "react";
import {
  Card,
  CardBody,
  Col,
  Row,
  Button,
  Badge,
  Modal,
  ModalHeader,
  ModalBody,
  ModalFooter
} from "reactstrap";
import { checkProblems } from "../../utils/checkProblems";
import ReportProblems from "../../components/Reports/ReportProblems";

class WidgetEnergyProblem extends Component {
  constructor(props) {
    super(props);
    this.state = {
      numProblems: 0,
      problems: false,
      large: false
    };
  }

  componentDidMount() {
    const result =
      this.props.data.queryResponse &&
      checkProblems(this.props.data.queryResponse);
    let numProblems = 0;
    Object.keys(result).forEach(key => {
      if (result[key].problem === true) numProblems += 1;
    });
    this.setState({
      numProblems: numProblems,
      problems: result
    });
  }

  toggleLarge = () => {
    this.setState({
      large: !this.state.large
    });
  };

  render() {
    console.log("Data of Energy Problem:");
    console.log(this.props.data);
    return (
      <Card className="widget-container">
        <CardBody className="widget-body">
          <Row className="widget-container-text">
            <Col md="8">
              <div
                style={{
                  display: "flex",
                  "justify-content": "space-between",
                  "align-items": "baseline"
                }}
              >
                <div className="widget-title">Diagnóstico</div>
                <Badge color="danger"> {this.state.numProblems} erro(s) </Badge>
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
                  onClick={this.toggleLarge}
                >
                  Relatório
                </Button>
                <ReportProblems
                  isOpen={this.state.large}
                  toggle={this.toggleLarge}
                  className={"modal-lg " + this.props.className}
                  problems={this.state.problems}
                />
              </div>
            </Col>
            <Col md="4" className="widget-container-image">
              <img
                className="widget-image"
                src={require("../../assets/icons/iconfinder_101_Warning_183416.png")}
              />
            </Col>
          </Row>
        </CardBody>
      </Card>
    );
  }
}

export default WidgetEnergyProblem;
