import React, { Component } from "react";
import {
  Card,
  CardHeader,
  CardBody,
  Row,
  Col,
  Label,
  Input,
  Button
} from "reactstrap";

class FormUserLogin extends Component {
  render() {
    return (
      <Card>
        <CardHeader>
          <Row>
            <Col md="12">
              <div className="calc-title">Login</div>
              <div className="calc-subtitle">
              </div>
            </Col>
          </Row>
        </CardHeader>
        <CardBody>
          <Row>
            <Col xl="3" lg="6">
              <Row style={{ marginBottom: "10px" }}>
                <Label htmlFor="email" className="label-form">
                  <strong>Email:</strong>
                </Label>
                <Input
                  className="date-input"
                  name="email"
                  id="email"
                  type="text"
                  placeholder="usuario@senado.leg.br"
                  required
                  onChange={this.props.handleInputs}
                />
              </Row>
            </Col>
            <Col xl="3" lg="6">
              <Row style={{ marginBottom: "10px" }}>
                <Label htmlFor="password" className="label-form">
                  <strong>Senha:</strong>
                </Label>
                  <Input
                    className="date-input"
                    type="password"
                    name="password"
                    id="password"
                    placeholder="Senha"
                    required
                    onChange={this.props.handleInputs}
                  />
              </Row>
            </Col>
          </Row>
          <Row>
            <Col xs="auto">
              <Button
                className=""
                type="submit"
                size="md"
                color="primary"
                onClick={this.props.handleSubmit}
                style={{ margin: "10px 20px" }}
              >
                Entrar
              </Button>
            </Col>
          </Row>
        </CardBody>
      </Card>
    );
  }
}

export default FormUserLogin;
