import React, { Component } from "react";
import { Card, CardHeader, CardBody, Row, Col, Button } from "reactstrap";
import EnergyResultOM from "./EnergyResultOM";
import EnergyResultOP from "./EnergyResultOP";
import EnergyResultAM from "./EnergyResultAM";
import EnergyResultAP from "./EnergyResultAP";

class EnergyResults extends Component {
  render() {
    return (
      <Card>
        <CardHeader>
          <Row>
            <Col md="6" />
            <Col md="4" />
            <Col md="2" className="container-left">
              <Button
                block
                outline
                color="primary"
                onClick={this.props.handleClick}
              >
                <i className="cui-magnifying-glass" />
                &nbsp;Nova Pesquisa
              </Button>
            </Col>
          </Row>
        </CardHeader>
        <CardBody>
          {this.props.energyState.oneMonth && this.props.energyState.chosenMeter !== "199" &&
            <EnergyResultOM energyState={this.props.energyState}></EnergyResultOM>
          }
          {!this.props.energyState.oneMonth && this.props.energyState.chosenMeter !== "199" &&
            <EnergyResultOP energyState={this.props.energyState}></EnergyResultOP>
          }
          {this.props.energyState.oneMonth && this.props.energyState.chosenMeter === "199" &&
            <EnergyResultAM energyState={this.props.energyState}></EnergyResultAM>       
          }
          {!this.props.energyState.oneMonth && this.props.energyState.chosenMeter === "199" &&
            <EnergyResultAP energyState={this.props.energyState}></EnergyResultAP>
          }
        </CardBody>
      </Card>
    );
  }
}

export default EnergyResults;