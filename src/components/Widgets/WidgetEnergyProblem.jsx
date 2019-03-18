import React, { Component } from "react";
import { Card, CardBody, Col, Row } from "reactstrap";

class WidgetEnergyProblem extends Component {
  state = {};
  render() {
    return (
      <Card className="widget-container">
        <CardBody className="widget-body">
          <Row className="widget-container-text">
            <Col md="8">
              <div>
                <div className="widget-title">Problemas</div>
                <div>
                  <ul>
                    <li>EREX</li>
                  </ul>
                </div>
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
