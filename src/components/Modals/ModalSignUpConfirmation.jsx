import React, { Component } from "react";
import {
  Row,
  Button,
  Modal,
  ModalHeader,
  ModalBody,
  Input,
  Container,
  Col,
  Form
} from "reactstrap";

class ModalSignUpConfirmation extends Component {
  constructor(props){
    super(props);
    this.state = {
      code: ""
    }
    this.handleCodeInput = this.handleCodeInput.bind(this);
    this.handleCodeSubmit = this.handleCodeSubmit.bind(this);
  }

  handleCodeInput(event){
    this.setState({
      [event.target.name]: event.target.value
    });
  }

  handleCodeSubmit(event){
    event.preventDefault();
    console.log('inside sendCode');
    this.props.user.confirmRegistration(this.state.code, true, (err, result) => {
      if (err) {
        console.log("Houve um problema.\n\nInsira novamente o código de verificação.\n\nCaso o problema persista, contate o administrador.");
      } else {
        console.log('Cadastro de usuário confirmado.\n\nFaça o login para começar.');
      }
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
        className="modal-lg"
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
                    <Form>
                      <p className="text-muted">
                        Insira no campo abaixo o código de verificação que foi enviado para o email
                      </p>
                      <p><strong>{email}</strong>.</p>
                      <Input
                        className="text-center mb-3 mt-4"
                        textalign="center"
                        type="text"
                        name="code"
                        id="code"
                        type="text"
                        placeholder="XXXXXX"
                        onChange={this.handleCodeInput}
                      />
                      <Button
                        block
                        type="submit"
                        size="md"
                        color="primary"
                        onClick={this.handleCodeSubmit}
                      >Enviar código de verificação
                      </Button>
                    </Form>
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
