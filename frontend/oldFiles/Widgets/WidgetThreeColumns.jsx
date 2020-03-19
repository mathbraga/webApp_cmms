import React, { Component } from "react";
import { Card, CardBody, Col, Row } from "reactstrap";

class WidgetThreeColumns extends Component {
  /* Props:
   *       - titles (list with 6 string): Title for all the values
   *       - values (list with 6 formatted numbers): All values
   *       - image (uri)
   */

  render() {
    //----------------------------------------
    // VARIABLES
    // Destructuring props
    const { titles, values, image } = this.props;
    //----------------------------------------

    return (
      <Card className="widget-container">
        <CardBody className="widget-body">
          <Row className="widget-container-text">
            <Col md="3" xs="4">
              <div className="widget-title text-truncate">{titles[0]}</div>
              <div className="text-truncate">{values[0]}</div>
              <div
                className="widget-title text-truncate"
                style={{ paddingTop: "5px" }}
              >
                {titles[1]}
              </div>
              <div className="text-truncate">{values[1]}</div>
            </Col>
            <Col md="3" xs="4" className="widget-division">
              <div className="widget-title text-truncate">{titles[2]}</div>
              <div className="text-truncate">{values[2]}</div>
              <div
                className="widget-title text-truncate"
                style={{ paddingTop: "5px" }}
              >
                {titles[3]}
              </div>
              <div className="text-truncate">{values[3]}</div>
            </Col>
            <Col md="3" xs="4" className="widget-division">
              <div className="widget-title text-truncate">{titles[4]}</div>
              <div className="text-truncate">{values[4]}</div>
              <div
                className="widget-title text-truncate"
                style={{ paddingTop: "5px" }}
              >
                {titles[5]}
              </div>
              <div className="text-truncate">{values[5]}</div>
            </Col>
            <Col md="3" className="widget-container-image d-none d-md-flex">
              <img className="widget-image" src={image} alt="Widget Image"/>
            </Col>
          </Row>
        </CardBody>
      </Card>
    );
  }
}

export default WidgetThreeColumns;
