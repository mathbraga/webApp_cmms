import React, { Component } from "react";
import { Card, CardBody, Col, Row, Button, CardHeader } from "reactstrap";

class AssetCard extends Component {
  /*
   * Input:
   *  Props:
   *    sectionName
   *    sectionDescription
   *    handleCardButton
   *    buttonName
   */

  render() {
    let {
      sectionName,
      sectionDescription,
      handleCardButton,
      buttonName,
      children
    } = this.props;

    return (
      <Card>
        <CardHeader>
          <Row>
            <Col md="9" xs="6">
              <div className="widget-title dash-title text-truncate">
                <h4>{sectionName}</h4>
                <div className="dash-subtitle text-truncate">
                  {sectionDescription}
                </div>
              </div>
            </Col>
            <Col md="3" xs="6" className="container-left">
              <Button
                className="text-truncate"
                block
                outline
                color="primary"
                onClick={handleCardButton}
                style={{ width: "auto", padding: "8px 25px" }}
              >
                {buttonName}
              </Button>
            </Col>
          </Row>
        </CardHeader>
        <CardBody>{children}</CardBody>
      </Card>
    );
  }
}

export default AssetCard;