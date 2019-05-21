import React, { Component } from "react";
import {
  Row,
  Button,
  Modal,
  ModalHeader,
  ModalBody,
  Input
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

  handleCodeSubmit(){
    console.log('inside sendCode');
    this.props.user.confirmRegistration(this.state.code, true, function(err, result) {
      if (err) {
        alert("Houve um problema.\n\nInsira novamente o código de verificação.\n\nCaso o problema persista, contate o administrador.");
        return;
      } else {
        alert('Cadastro de usuário confirmado.\n\nFaça o login para começar.');
      }
    });
  }
  
  render() {

    let {
      isOpen,
      toggle,
      className,
      email
    } = this.props;

    return (
      <Modal
        isOpen={isOpen}
        toggle={toggle}
        className={className}
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
          <Row>
            <p>
              Insira abaixo o código que foi enviado para o email
              &nbsp;
              <strong>
                {email}
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
              onClick={this.handleCodeSubmit}
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
