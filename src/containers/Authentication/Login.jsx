import React, { Component } from "react";
import { Link } from "react-router-dom";
import { Alert, Button, Card, CardBody, CardGroup, Col, Container, Form, Input, InputGroup, InputGroupAddon, InputGroupText, Row } from 'reactstrap';


class Login extends Component {
  constructor(props){
    super(props);
  }

  render() {
    return (
      <React.Fragment>
        <div className="flex-row align-items-center">
          <Container>
            <Row className="justify-content-center">
              <Col md="8">
                <CardGroup>
                  <Card className="p-4">
                    <CardBody>
                      <Form>
                        <h1>Login</h1>
                        <p className="text-muted">Faça login em sua conta</p>
                        <InputGroup className="mb-3">
                          <InputGroupAddon addonType="prepend">
                            <InputGroupText>
                              <i className="icon-user"></i>
                            </InputGroupText>
                          </InputGroupAddon>
                          <Input
                            type="text"
                            id="email"
                            name="email"
                            placeholder="usuario@senado.leg.br"
                            autoComplete="username"
                            onChange={this.props.handleLoginInputs}
                          />
                        </InputGroup>
                        <InputGroup className="mb-4">
                          <InputGroupAddon addonType="prepend">
                            <InputGroupText>
                              <i className="icon-lock"></i>
                            </InputGroupText>
                          </InputGroupAddon>
                          <Input
                            type="password"
                            id="password"
                            name="password"
                            placeholder="senha"
                            autoComplete="current-password"
                            onChange={this.props.handleLoginInputs}  
                          />
                        </InputGroup>
                        <Row>
                          <Col xs="6">
                            <Button
                              color="primary"
                              className="px-4"
                              onClick={this.props.handleLoginSubmit}  
                            >Login</Button>
                          </Col>
                          <Col xs="6" className="text-right">
                            <Button
                              color="link"
                              className="px-0"
                              onClick={"TODO"}
                            >Esqueceu sua senha?
                            </Button>
                          </Col>
                        </Row>
                      </Form>
                    </CardBody>
                  </Card>
                  <Card className="text-white bg-primary py-5 d-md-down-none" style={{ width: '44%' }}>
                    <CardBody className="text-center">
                      <div>
                        <h2>Cadastro</h2>
                        <p>Cadastro disponível apenas para servidores da SINFRA.</p>
                        <Link to="/cadastro">
                          <Button color="primary" className="mt-3" active tabIndex={-1}>Cadastrar</Button>
                        </Link>
                      </div>
                    </CardBody>
                  </Card>
                </CardGroup>
                <Alert className="mt-4" color="danger" isOpen={this.props.alertVisible} toggle={this.props.handleAlertDismiss}>
                  Login falhou. Tente novamente.
                </Alert>
              </Col>
            </Row>
          </Container>
        </div>
      </React.Fragment>
    );
  }
}

export default Login;
