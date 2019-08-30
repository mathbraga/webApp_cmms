import React, { Component } from "react";
import { Alert, Button, Card, CardBody, Col, Container, Form, Input, InputGroup, InputGroupAddon, InputGroupText, Row } from 'reactstrap';
import login from "../../utils/authentication/login";
import ModalForgottenPassword from "../../components/Modals/ModalForgottenPassword";

class Login extends Component {
  constructor(props){
    super(props);
    this.state = {
      email: "",
      password: "",
      isFetching: false,
      loginError: false,
      alertVisible: false,
      modalVisible: false
    }
  }

  handleInputs = event => {
    this.setState({
      [event.target.name]: event.target.value
    });
  }

  handleSubmit = event => {
    event.preventDefault();
    this.setState({
      isFetching: true,
      alertVisible: true,
      alertMessage: "Realizando login...",
      loginError: false,
    });
    login(this.state.email, this.state.password)
      .then(() => {
        this.props.history.push("/painel")
      })
      .catch(alertMessage => {
        this.setState({
          isFetching: false,
          loginError: true,
          alertVisible: true,
          alertMessage: alertMessage
        })
      });
  }

  closeAlert = event => {
    this.setState({
      alertVisible: false
    });
  }

  openModal = () => {
    this.setState({
      modalVisible: true
    });
  }

  closeModal = () => {
    this.setState({
      modalVisible: false
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
                          value={this.state.email}
                          placeholder="usuario@senado.leg.br"
                          autoComplete="username"
                          onChange={this.handleInputs}
                          disabled={this.state.isFetching}
                          autoFocus
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
                          value={this.state.password}
                          placeholder="Senha"
                          autoComplete="current-password"
                          onChange={this.handleInputs}
                          disabled={this.state.isFetching}
                        />
                      </InputGroup>

                      <Row>
                        <Col xs="6">
                          <Button
                            block
                            color="primary"
                            className="px-4"
                            onClick={this.handleSubmit}  
                            disabled={this.state.isFetching}
                          >Login</Button>
                        </Col>
                        <Col xs="6" className="text-right">
                          <Button
                            block
                            outline
                            color="primary"
                            className="px-0"
                            onClick={this.openModal}
                            disabled={this.state.isFetching}
                          >Esqueceu sua senha?
                          </Button>
                        </Col>
                      </Row>
                    </Form>
                  </CardBody>
                </Card>

                <Alert
                  className="mt-4 mx-4"
                  color={this.state.loginError ? "danger": "warning"}
                  isOpen={this.state.alertVisible}
                  toggle={this.closeAlert}
                >{this.state.alertMessage}
                </Alert>

              </Col>
            </Row>
          </Container>
        </div>

        <ModalForgottenPassword
          isOpen={this.state.modalVisible}
          toggle={this.closeModal}
        />

      </React.Fragment>
    );
  }
}

export default Login;