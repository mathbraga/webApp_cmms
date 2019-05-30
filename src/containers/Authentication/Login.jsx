import React, { Component } from "react";
import { Link } from "react-router-dom";
import { Alert, Button, Card, CardBody, CardGroup, Col, Container, Form, Input, InputGroup, InputGroupAddon, InputGroupText, Row } from 'reactstrap';
import loginCognito from "../../utils/authentication/loginCognito";
import { startSession } from "../../redux/actions";
import { connect } from "react-redux";

class Login extends Component {
  constructor(props){
    super(props);
    this.state = {
      email: "",
      password: "",
      loggedIn: false,
      alertVisible: false
    }
    this.handleLoginInputs = this.handleLoginInputs.bind(this);
    this.handleLoginSubmit = this.handleLoginSubmit.bind(this);
    this.handleAlertDismiss = this.handleAlertDismiss.bind(this);
  }

  handleLoginInputs(event){
    this.setState({
      [event.target.name]: event.target.value
    });
  }

  handleLoginSubmit(event){
    event.preventDefault();
    loginCognito(this.state.email, this.state.password).then(userSession => {
      if(userSession){
        this.props.startSession(userSession);
        this.props.history.push("/");
      } else {
        this.setState({
          alertVisible: true,
          email: "",
          password: ""
        });
      }
    }).catch(() => {
      this.setState({
        alertVisible: true,
        email: "",
        password: ""
      });
    });
  }

  handleAlertDismiss() {
    this.setState({
      alertVisible: false
    });
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
                            onChange={this.handleLoginInputs}
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
                            onChange={this.handleLoginInputs}  
                          />
                        </InputGroup>
                        <Row>
                          <Col xs="6">
                            <Button
                              color="primary"
                              className="px-4"
                              onClick={this.handleLoginSubmit}  
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
                <Alert className="mt-4" color="danger" isOpen={this.state.alertVisible} toggle={this.handleAlertDismiss}>
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

export default connect(
  null,
  { startSession }
)(Login);