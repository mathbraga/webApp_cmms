import React, { Component } from "react";
import {
  Alert,
  Row,
  Button,
  Modal,
  ModalHeader,
  ModalBody,
  Input,
  Container,
  Col,
  Form,
  InputGroup,
  InputGroupAddon,
  InputGroupText
} from "reactstrap";
import forgotCognito from "../../utils/authentication/forgotCognito";
import setNewPasswordCognito from "../../utils/authentication/setNewPasswordCognito";

class ModalForgottenPassword extends Component {
  constructor(props){
    super(props);
    this.state = {
      email: "",
      code: "",
      codeSent: false,
      newPasswordOK: false
    }
    this.handleChangeInputs = this.handleChangeInputs.bind(this);
    this.requestCode = this.requestCode.bind(this);
    this.handleNewPassword = this.handleNewPassword.bind(this);
  }

  handleChangeInputs(event){
    this.setState({
      [event.target.name]: event.target.value
    });
  }

  requestCode(event){
    event.preventDefault();
    forgotCognito(this.state.email).then(response => {
      if(response){
        console.log("Código de verificação enviado para o email.");
        this.setState({
          codeSent: true
        });
      } else {
        console.log("Não foi possível enviar o código de verificação.");
      }
    });
  }

  handleNewPassword(event){
    event.preventDefault();
    setNewPasswordCognito(this.state.email, this.state.code, this.state.newPassword1, this.state.newPassword2).then(response => {
      if(response){
        console.log("Nova senha cadastrada com sucesso!");
        this.setState({
          newPasswordOK: true
        })
      } else {
        console.log("Ocorreu um erro. Não foi possível atualizar a senha.");
      }
    });
  }
  
  render() {

    let {
      toggle,
      isOpen
    } = this.props;

    return (
      <Modal
        isOpen={isOpen}
        toggle={toggle}
        className="modal-md"
      >
        <ModalHeader toggle={toggle}>
          <Row style={{ padding: "0px 20px" }}>
            <div className="widget-title">
              <h4>
                Esqueci minha senha
              </h4>
            </div>
          </Row>
        </ModalHeader>
        <ModalBody style={{ overflow: "scroll", alignContent: "center" }}>
          <div className="flex-row align-items-center">
            <Container>
              <Row className="justify-content-center">
                <Col md="12">
                  <div className="p-4 text-center">

                    {!this.state.codeSent && !this.state.newPasswordOK &&

                      <Form>
                        <p className="text-muted">
                          Insira seu email no campo abaixo para solicitar o código de verificação e cadastrar uma nova senha.
                        </p>
                        <InputGroup className="mb-3 mt-3">
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
                            onChange={this.handleChangeInputs}
                          />
                        </InputGroup>
                        <Button
                          block
                          type="submit"
                          size="md"
                          color="primary"
                          onClick={this.requestCode}
                        >Solicitar código de verificação
                        </Button>
                      </Form>
                    }

                    {this.state.codeSent && !this.state.newPasswordOK &&
                      <React.Fragment>

                        <p className="text-muted">
                          Insira o código de verificação que foi enviado para o email
                          <strong>{" " + this.state.email + " "}</strong>
                          e defina a nova senha.
                        </p>
                        <InputGroup className="mb-3">
                          <InputGroupAddon addonType="prepend">
                            <InputGroupText>
                              <i className="fa fa-exclamation-triangle"></i>
                            </InputGroupText>
                          </InputGroupAddon>
                          <Input
                            type="text"
                            id="code"
                            name="code"
                            placeholder="Código de verificação (XXXXXX)"
                            onChange={this.handleChangeInputs}  
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
                            id="newPassword1"
                            name="newPassword1"
                            placeholder="Nova senha"
                            onChange={this.handleChangeInputs}  
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
                            id="newPassword2"
                            name="newPassword2"
                            placeholder="Repita a nova senha"
                            onChange={this.handleChangeInputs}  
                          />
                        </InputGroup>

                        <Button
                          block
                          type="submit"
                          size="md"
                          color="primary"
                          onClick={this.handleNewPassword}
                        >Atualizar senha
                        </Button>

                      </React.Fragment>
                    }

                    <Alert className="mt-4 mx-4" color="success" isOpen={this.state.newPasswordOK}>
                      Nova senha cadastrada com sucesso.
                    </Alert>

                  </div>
                </Col>
              </Row>
            </Container>
          </div>
        </ModalBody>
      </Modal>
    );
  }
}

export default ModalForgottenPassword;
