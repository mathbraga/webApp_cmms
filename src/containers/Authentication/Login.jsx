import React, { Component } from "react";
import { Link } from "react-router-dom";
import { Alert, Button, Card, CardBody, CardGroup, Col, Container, Form, Input, InputGroup, InputGroupAddon, InputGroupText, Row } from 'reactstrap';
import { login } from "../../redux/actions";
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
    this.props.dispatch(login(this.state.email, this.state.password));
    // this.props.history.push("/painel");
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
              <Col md="6">
                <Card className="mx-4">
                  <CardBody className="p-4">
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
                          placeholder="Senha"
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

                <Alert className="mt-4" color="danger" isOpen={this.props.error} toggle={this.handleAlertDismiss}>
                  Login falhou. Tente novamente.
                </Alert>

                <Alert className="mt-4" color="warning" isOpen={this.props.fetching} toggle={this.handleAlertDismiss}>
                  REALIZANDO LOGIN
                </Alert>


              </Col>
            </Row>
          </Container>
        </div>
      </React.Fragment>
    );
  }
}

const mapStateToProps = storeState => {
  let fetching = storeState.userSession.isFetching;
  let error = storeState.userSession.error;
  return {
    fetching,
    error
  }
}

export default connect(mapStateToProps)(Login);