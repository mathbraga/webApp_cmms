import React, { Component } from "react";
import ModalSignUpConfirmation from "../../components/Modals/ModalSignUpConfirmation";
import signUpCognito from "../../utils/authentication/signUpCognito";
import { Alert, Button, Card, CardBody, Col, Container, Form, Input, InputGroup, InputGroupAddon, InputGroupText, Row } from 'reactstrap';

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
      if(user){
        this.setState({
          user: user,
          alertVisible: false,
          modal: true
        });
      } else {
        this.setState({
          alertVisible: true
        });
      }
    });
  }

  toggleModal = () => {
    this.setState(prevState => {
      return {modal: !prevState.modal}
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

        <ModalSignUpConfirmation
          isOpen={this.state.modal}
          toggle={this.toggleModal}
          user={this.state.user}
          email={this.state.email}
          className="modal-lg"
        />

        <div className="flex-row align-items-center">
          <Container>
            <Row className="justify-content-center">
              <Col md="9" lg="7" xl="6">
                <Card className="mx-4">
                  <CardBody className="p-4">
                    <Form>
                      <h1>Cadastro</h1>
                      <p className="text-muted">Crie sua conta</p>
                      <InputGroup className="mb-3">
                        <InputGroupAddon addonType="prepend">
                          <InputGroupText>@</InputGroupText>
                        </InputGroupAddon>
                        <Input
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
                          type="password"
                          placeholder="Repita sua senha"
                          id="password2"
                          name="password2"
                          autoComplete="new-password"
                          onChange={this.handleInputs}
                        />
                      </InputGroup>
                      <Button
                        color="primary"
                        block
                        onClick={this.handleSubmit}
                        >Cadastrar
                      </Button>
                    </Form>
                  </CardBody>
                </Card>

                <Alert color="danger" isOpen={this.state.alertVisible} toggle={this.onAlertDismiss}>
                  Cadastro falhou. Tente novamente.
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
