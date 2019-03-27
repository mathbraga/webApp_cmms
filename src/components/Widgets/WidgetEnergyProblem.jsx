import React, { Component } from "react";
import { Card, CardBody, Col, Row, Button, Badge } from "reactstrap";

class WidgetEnergyProblem extends Component {
  state = {};
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
                <Badge color="danger"> 3 vícios </Badge>
              </div>

              <div
                style={{
                  display: "flex",
                  "flex-flow": "column",
                  "justify-content": "center",
                  height: "70%"
                }}
              >
                <Button outline color="primary" size="sm">
                  Relatório
                </Button>
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
