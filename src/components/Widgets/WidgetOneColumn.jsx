import React, { Component } from "react";
import { Card, CardBody, Col, Row } from "reactstrap";

class WidgetOneColumn extends Component {
  /* Props:
   *       - firstTitle (string)
   *       - firstValue (number formatted)
   *       - secondTitle (string)
   *       - secondValue (number formatted)
   *       - image (uri)
   */

  render() {
    // --------------------------------
    // VARIABLES
    // Destructuring props
    const {
      firstTitle,
      firstValue,
      secondTitle,
      secondValue,
      image
    } = this.props;
    // --------------------------------

    return (
      <Card className="widget-container">
        <CardBody className="widget-body">
          <Row>
            <Col md="7" className="col-widget">
              <div className="widget-title">{firstTitle}</div>
              <div>{firstValue}</div>
              <div className="widget-title" style={{ "padding-top": "5px" }}>
                {secondTitle}
              </div>
              <div>{secondValue}</div>
            </Col>
            <Col md="5" className="widget-container-image">
              <img className="widget-image" src={image} />
            </Col>
          </Row>
        </CardBody>
      </Card>
    );
  }
}

export default WidgetOneColumn;
