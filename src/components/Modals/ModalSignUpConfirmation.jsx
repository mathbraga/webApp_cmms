import React, { Component } from "react";
import {
  Row,
  Button,
  Modal,
  ModalHeader,
  ModalBody,
  ModalFooter,
  Input
} from "reactstrap";
import {
  CognitoUserPool,
  CognitoUserAttribute,
  CognitoUser
} from "amazon-cognito-identity-js";

class ModalSignUpConfirmation extends Component {
  constructor(props){
    super(props);
    this.state = {
      code: ""
    }
    this.handleCodeInput = this.handleCodeInput.bind(this);
    this.sendCode = this.sendCode.bind(this);
  }

  handleCodeInput(event){
    this.setState({
      [event.target.name]: event.target.value
    });
  }

  sendCode(){

    console.log('inside sendCode');

    // Se está ok, fecha o modal e avisa que deu certo.
    this.props.user.confirmRegistration(this.state.code, true, function(err, result) {
      if (err) {
        alert(err);
        return;
      } else {
        console.log('Usuário confirmado');
        console.log(result);
      }
    });


    // Se não está correto, pede novamente o código.

  }
  
  render() {
    return (
      <Modal
        isOpen={this.props.isOpen}
        toggle={this.props.toggle}
        className={this.props.className}
      >
        <ModalHeader toggle={this.props.toggle}>
          <Row style={{ padding: "0px 20px" }}>
            <div className="widget-title">
              <h4>
                Confirmação de cadastro
              </h4>
            </div>
          </Row>
        </ModalHeader>
        <ModalBody style={{ overflow: "scroll", alignContent: "center" }}>
          <Row>
            <p>
              Insira abaixo o código que foi enviado para o email
              &nbsp;
              <strong>
                {this.props.email}
              </strong>
              .
            </p>
          </Row>
          <Row>
            <Input
              className="date-input"
              name="code"
              id="code"
              type="text"
              placeholder=""
              value={this.state.code}
              required
              onChange={this.handleCodeInput}
            />
          </Row>
          <Row>
            <Button
              className=""
              type="submit"
              size="md"
              color="primary"
              onClick={this.sendCode}
              style={{ margin: "10px 20px" }}
            >
              Enviar código
            </Button>
          </Row>
        </ModalBody>
      </Modal>
    );
  }
}

export default ModalSignUpConfirmation;
