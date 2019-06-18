import React, { Component } from "react";
import { Card, CardBody, Col, Row, Button, CardHeader } from "reactstrap";

const configIcon = require("../../assets/icons/config_icon.png");

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
            <Col md="8" xs="6">
              <div className="widget-title dash-title text-truncate">
                <h4>{sectionName}</h4>
                <div className="dash-subtitle text-truncate">
                  {sectionDescription}
                </div>
              </div>
            </Col>
            <Col md="4" xs="6" className="container-left">
              <Button
                className="text-truncate"
                block
                outline
                color="dark"
                onClick={handleCardButton}
                style={{ width: "auto", padding: "8px 40px" }}
              >
                {buttonName}
              </Button>
              <Button
                color="dark"
                outline
                style={{ width: "41px", height: "41px", marginLeft: "20px", padding: "6px" }}
              >
                <img src={configIcon} alt="" style={{ width: "100%", height: "100%" }} />
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