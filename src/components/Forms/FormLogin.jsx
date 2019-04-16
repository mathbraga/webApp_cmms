import React, { Component } from "react";
import {
  Card,
  CardHeader,
  CardBody,
  Row,
  Col,
  Label,
  Input,
  FormGroup,
  Button,
  CustomInput
} from "reactstrap";

class FormLogin extends Component {
  constructor(props){
    super(props);
    this.state = {
      userName: "",
      password: ""
    }
  }
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
                <Label htmlFor="initialDate" className="label-form">
                  <strong>Usuário:</strong>
                </Label>
                <Input
                  className="date-input"
                  name="username"
                  id="username"
                  type="text"
                  placeholder="Nome de usuário"
                  required
                  onChange={this.props.handleLoginInputs}
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
                    type="text"
                    name="password"
                    id="password"
                    placeholder="Senha"
                    required
                    onChange={this.props.handleLoginInputs}
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
                onClick={this.props.handleLoginSubmit}
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

export default FormLogin;
