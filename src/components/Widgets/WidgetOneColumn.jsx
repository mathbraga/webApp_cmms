import React, { Component } from "react";
import { Card, CardBody } from "reactstrap";

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
          <div className="container">
            <div className="row ">
              <div className="col-8 px-0">
                <div className="widget-title">{firstTitle}</div>
                <div>{firstValue}</div>
                <div className="widget-title" style={{ "padding-top": "5px" }}>
                  {secondTitle}
                </div>
                <div className="text-truncate">{secondValue}</div>
              </div>
              <div className="col-4 widget-container-image">
                <img className="widget-image" src={image} alt=""/>
              </div>
            </div>
          </div>
        </CardBody>
      </Card>
    );
  }
}

export default WidgetOneColumn;
