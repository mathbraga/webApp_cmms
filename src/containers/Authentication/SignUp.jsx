import React, { Component } from "react";
import ModalSignUpConfirmation from "../../components/Modals/ModalSignUpConfirmation";
import signUpCognito from "../../utils/authentication/signUpCognito";
import { Alert, Button, Card, CardBody, Col, Container, Form, Input, InputGroup, InputGroupAddon, InputGroupText, Row } from 'reactstrap';
import { Route } from "react-router-dom";

class SignUp extends Component {
  constructor(props){
    super(props);
    this.state = {
      email: "",
      password1: "",
      password2: "",
      user: false,
      modal: false,
      alertVisible: false
    }
    this.handleInputs = this.handleInputs.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
    this.onAlertDismiss = this.onAlertDismiss.bind(this);
  }

  handleInputs(event){
    this.setState({
      [event.target.name]: event.target.value
    });
  }

  handleSubmit(event){
    event.preventDefault();
    signUpCognito(this.state.email, this.state.password1, this.state.password2).then(user => {
      console.log("Usuário cadastrado com o email " + user.getUsername());
      this.setState({
        user: user,
        alertVisible: false,
        modal: true
      });
    }).catch(() => {
      this.setState({
        alertVisible: true
      });
    });
  }

  closeModal = () => {
    this.setState({
      modal: false
    });
  };

  onAlertDismiss() {
    this.setState({
      alertVisible: false
    });
  }

  render() {
    return (
      <React.Fragment>

        <Route
          render={(routerProps) => (
            <ModalSignUpConfirmation
              {...routerProps}
              isOpen={this.state.modal}
              toggle={this.closeModal}
              user={this.state.user}
              email={this.state.email}
          />)}
        />

        <div className="flex-row align-items-center">
          <Container>
            <Row className="justify-content-center">
              <Col md="6">
                <Card className="mx-4">
                  <CardBody className="p-4">
                    <Form>
                      <h1>Cadastro</h1>
                      <p className="text-muted">Crie sua conta.</p>
                      <InputGroup className="mb-3">
                        <InputGroupAddon addonType="prepend">
                          <InputGroupText>@</InputGroupText>
                        </InputGroupAddon>
                        <Input
                          disabled
                          type="text"
                          id="email"
                          name="email"
                          placeholder="usuario@senado.leg.br"
                          autoComplete="email"
                          onChange={this.handleInputs}
                        />
                      </InputGroup>
                      <InputGroup className="mb-3">
                        <InputGroupAddon addonType="prepend">
                          <InputGroupText>
                            <i className="icon-lock"></i>
                          </InputGroupText>
                        </InputGroupAddon>
                        <Input
                          disabled
                          type="password"
                          placeholder="Senha"
                          id="password1"
                          name="password1"
                          autoComplete="new-password"
                          onChange={this.handleInputs}
                        />
                      </InputGroup>
                      <InputGroup className="mb-4">
                        <InputGroupAddon addonType="prepend">
                          <InputGroupText>
                            <i className="icon-lock"></i>
                          </InputGroupText>
                        </InputGroupAddon>
                        <Input
                          disabled
                          type="password"
                          placeholder="Repita sua senha"
                          id="password2"
                          name="password2"
                          autoComplete="new-password"
                          onChange={this.handleInputs}
                        />
                      </InputGroup>
                      <Button
                        disabled
                        color="primary"
                        block
                        onClick={this.handleSubmit}
                        >Cadastrar
                      </Button>
                    </Form>
                  </CardBody>
                </Card>

                <Alert className="mt-4 mx-4" color="danger" isOpen={true}>
                  Cadastro não disponível no momento.
                </Alert>
                
              </Col>
            </Row>
          </Container>
        </div>

      </React.Fragment>
    );
  }
}

export default SignUp;
