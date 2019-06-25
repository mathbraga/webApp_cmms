import React, { Component } from "react";
import ModalSignUpConfirmation from "../../components/Modals/ModalSignUpConfirmation";
import signUpCognito from "../../utils/authentication/signUpCognito";
import { Alert, Button, Card, CardBody, Col, Container, Form, Input, InputGroup, InputGroupAddon, InputGroupText, Row } from 'reactstrap';
import { Route } from "react-router-dom";

class SignUp extends Component {
  constructor(props){
    super(props);
    this.emailInputRef = React.createRef();
    this.password1InputRef = React.createRef();
    this.password2InputRef = React.createRef();
    this.state = {
      email: "",
      password1: "",
      password2: "",
      user: false,
      modal: false,
      alertVisible: false
    }
  }

  handleInputs = event => {
    this.setState({
      [event.target.name]: event.target.value
    });
  }

  handleSubmit = event => {
    event.preventDefault();
    signUpCognito(this.state.email, this.state.password1, this.state.password2).then(user => {
      if(user){
        this.setState({
          user: user,
          modal: true,
          alertVisible: false
        });
      } else {
        this.setState({
          alertVisible: true,
          email: "",
          password1: "",
          password2: ""
        });
        this.emailInputRef.current.value = "";
        this.password1InputRef.current.value = "";
        this.password2InputRef.current.value = "";
      }
    });
  }

  closeModal = () => {
    this.setState({
      modal: false
    });
  };

  closeAlert = () => {
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
                          <InputGroupText>
                            <i className="icon-user"></i>
                          </InputGroupText>
                        </InputGroupAddon>
                        <Input
                          type="text"
                          id="email"
                          name="email"
                          placeholder="usuario@senado.leg.br"
                          onChange={this.handleInputs}
                          innerRef={this.emailInputRef}
                          autoFocus
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
                          onChange={this.handleInputs}
                          innerRef={this.password1InputRef}
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
                          onChange={this.handleInputs}
                          innerRef={this.password2InputRef}
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

                {/* <Alert className="mt-4 mx-4" color="danger" isOpen={true}>
                  Cadastro não disponível no momento.
                </Alert> */}

                <Alert className="mt-4 mx-4" color="danger" isOpen={this.state.alertVisible} toggle={this.closeAlert}>
                  Cadastro falhou.
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
