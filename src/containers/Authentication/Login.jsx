import React, { Component } from "react";
import { Redirect, Route } from "react-router-dom";
import { Alert, Button, Card, CardBody, Col, Container, Form, Input, InputGroup, InputGroupAddon, InputGroupText, Row } from 'reactstrap';
import { login } from "../../redux/actions";
import { connect } from "react-redux";
import ModalForgottenPassword from "../../components/Modals/ModalForgottenPassword";

class Login extends Component {
  constructor(props){
    super(props);
    this.state = {
      email: "",
      password: "",
      alertVisible: false,
      modal: false
    }
    this.handleLoginInputs = this.handleLoginInputs.bind(this);
    this.handleLoginSubmit = this.handleLoginSubmit.bind(this);
    this.closeAlert = this.closeAlert.bind(this);
    this.openModal = this.openModal.bind(this);
  }

  componentDidUpdate(prevProps){
    if(this.props.loginError !== prevProps.loginError){
      this.setState({
        alertVisible: true
      });
    }
  }

  handleLoginInputs(event){
    this.setState({
      [event.target.name]: event.target.value
    });
  }

  handleLoginSubmit(event){
    event.preventDefault();
    this.props.dispatch(login(this.state.email, this.state.password));
  }

  closeAlert() {
    this.setState({
      alertVisible: false
    });
  }

  openModal = () => {
    this.setState({
      modal: true
    });
  }

  closeModal = () => {
    this.setState({
      modal: false
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
                      <p className="text-muted">Faça login em sua conta.</p>
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
                            block
                            color="primary"
                            className="px-4"
                            onClick={this.handleLoginSubmit}  
                          >Login</Button>
                        </Col>
                        <Col xs="6" className="text-right">
                          <Button
                            block
                            color="link"
                            className="px-0"
                            onClick={this.openModal}
                          >Esqueceu sua senha?
                          </Button>
                        </Col>
                      </Row>
                    </Form>
                  </CardBody>
                </Card>

                <Alert className="mt-4 mx-4" color="warning" isOpen={this.props.isFetching}>
                  Realizando login...
                </Alert>

                {!this.props.isFetching &&
                  <Alert className="mt-4 mx-4" color="danger" isOpen={this.state.alertVisible} toggle={this.closeAlert}>
                    Login falhou. Tente novamente.
                  </Alert>
                }

                {this.props.session &&
                  <Redirect to="/painel"/>
                }

              </Col>
            </Row>
          </Container>
        </div>

        <ModalForgottenPassword
          isOpen={this.state.modal}
          toggle={this.closeModal}
        />

      </React.Fragment>
    );
  }
}

const mapStateToProps = storeState => {
  let isFetching = storeState.auth.isFetching;
  let loginError = storeState.auth.loginError;
  let session = storeState.auth.session;
  return {
    isFetching: isFetching,
    loginError: loginError,
    session: session
  }
}

export default connect(mapStateToProps)(Login);