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
            <Col md="3">
              <div className="widget-title">{titles[0]}</div>
              <div>{values[0]}</div>
              <div className="widget-title" style={{ "padding-top": "5px" }}>
                {titles[1]}
              </div>
              <div>{values[1]}</div>
            </Col>
            <Col md="3">
              <div className="widget-division">
                <div className="widget-title">{titles[2]}</div>
                <div>{values[2]}</div>
                <div className="widget-title" style={{ "padding-top": "5px" }}>
                  {titles[3]}
                </div>
                <div>{values[3]}</div>
              </div>
            </Col>
            <Col md="3">
              <div className="widget-division">
                <div className="widget-title">{titles[4]}</div>
                <div>{values[4]}</div>
                <div className="widget-title" style={{ "padding-top": "5px" }}>
                  {titles[5]}
                </div>
                <div>{values[5]}</div>
              </div>
            </Col>
            <Col xl="3" className="d-none d-xl-block widget-container-image">
              <img className="widget-image" src={image} />
            </Col>
          </Row>
        </CardBody>
      </Card>
    );
  }
}

export default WidgetThreeColumns;
