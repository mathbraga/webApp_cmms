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

class FormUserSignUp extends Component {
  render() {
    return (
      <Card>
        <CardHeader>
          <Row>
            <Col md="auto">
              <div className="calc-title">Cadastro</div>
              <div className="calc-subtitle">
              </div>
            </Col>
          </Row>
        </CardHeader>
        <CardBody>
          <Row>
            <Col xsl="auto">
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
          </Row>
          <Row>
            <Col xs="auto">
              <Row style={{ marginBottom: "10px" }}>
                <Label htmlFor="password" className="label-form">
                  <strong>Senha:</strong>
                </Label>
                  <Input
                    className="date-input"
                    type="password"
                    name="password1"
                    id="password1"
                    placeholder="Senha"
                    required
                    onChange={this.props.handleInputs}
                  />
              </Row>
            </Col>
          </Row>
          <Row>
            <Col xs="auto">
              <Row style={{ marginBottom: "10px" }}>
                <Label htmlFor="password" className="label-form">
                  <strong>Repita senha:</strong>
                </Label>
                  <Input
                    className="date-input"
                    type="password"
                    name="password2"
                    id="password2"
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
                Cadastrar
              </Button>
            </Col>
          </Row>
        </CardBody>
      </Card>
    );
  }
}

export default FormUserSignUp;
