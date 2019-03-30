import React, { Component, Suspense } from "react";
import { Card, CardHeader, CardBody, Row, Col, Button } from "reactstrap";
import { Redirect, Route, Switch , HashRouter, Link} from "react-router-dom";
import EnergyResultOM from "./EnergyResultOM";
import EnergyResultOP from "./EnergyResultOP";
import EnergyResultAM from "./EnergyResultAM";
import EnergyResultAP from "./EnergyResultAP";
import routes from "../../routes";

class EnergyResults extends Component {
  constructor(props){
    super(props);
  }

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
          
            <Redirect to={this.props.location.state.newRoute} />

        </CardBody>
      </Card>
    );
  }
}

export default EnergyResults;