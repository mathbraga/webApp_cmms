import React, { Component } from "react";
import { Card, CardHeader, CardBody, Row, Col, Button } from "reactstrap";
import { Route, Switch } from "react-router-dom";
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
          <Switch location={this.props.energyState.newLocation}>
            <Route
              path="/consumo/energia/resultados/OM"
              render={() => (
                <EnergyResultOM energyState={this.props.energyState}/>
              )}
            />
            <Route
              path="/consumo/energia/resultados/OP"
              render={() => (
                <EnergyResultOP energyState={this.props.energyState}/>
              )}
            />
            <Route
              path="/consumo/energia/resultados/AM"
              render={() => (
                <EnergyResultAM energyState={this.props.energyState}/>
              )}
            />
            <Route
              path="/consumo/energia/resultados/AP"
              render={() => (
                <EnergyResultAP energyState={this.props.energyState}/>
              )}
            />
          </Switch>
        </CardBody>
      </Card>
    );
  }
}

export default EnergyResults;