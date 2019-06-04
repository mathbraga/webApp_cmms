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
import { Redirect } from "react-router-dom";

class ModalSignUpConfirmation extends Component {
  constructor(props){
    super(props);
    this.state = {
      code: "",
      signUpOK: false,
      signUpError: false,
      redirect: false
    }
  }

  handleCodeInput = event => {
    this.setState({
      [event.target.name]: event.target.value
    });
  }

  handleCodeSubmit = event => {
    event.preventDefault();
    this.props.user.confirmRegistration(this.state.code, true, (err, result) => {
      if (err) {
        this.setState({
          signUpOK: false,
          signUpError: true
        });
      } else {
        this.setState({
          signUpOK: true,
          signUpError: false
        });
      }
    });
  }

  handleRedirect = () => {
    this.setState({
      redirect: true
    });
  }
  
  render() {

    let {
      email,
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
                Confirmação de cadastro
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

                    {!this.state.signUpOK &&
                      <Form>
                        <p className="text-muted">
                          Para finalizar seu cadastro, insira no campo abaixo o código de verificação que foi enviado para o email
                        </p>
                        <p><strong>{email}</strong>.</p>
                          <InputGroup className="mb-4">
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
                              onChange={this.handleCodeInput}  
                            />
                          </InputGroup>    
                          <Button
                            block
                            type="submit"
                            size="md"
                            color="primary"
                            onClick={this.handleCodeSubmit}
                          >Confirmar cadastro
                          </Button>
                        </Form>
                      }

                      {this.state.signUpOK &&
                        <React.Fragment>
                          <Alert className="mt-4 mx-4" color="success" isOpen={this.state.signUpOK}>
                          Novo usuário cadastrado com sucesso.
                          </Alert>
                          <Button color="link" onClick={this.handleRedirect}>
                            Ir para a página de login.
                          </Button>
                        </React.Fragment>
                      }

                      {this.state.redirect &&
                        <Redirect to="/login"/>
                      }

                      <Alert className="mt-4 mx-4" color="danger" isOpen={this.state.signUpError}>
                        Não foi possível cadastrar o novo usuário. Verifique se o código inserido está correto e tente novamente.
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

export default ModalSignUpConfirmation;
