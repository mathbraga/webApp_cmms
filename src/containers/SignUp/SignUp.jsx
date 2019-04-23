import React, { Component } from "react";
import FormUserSignUp from "../../components/Forms/FormUserSignUp";
import ModalSignUpConfirmation from "../../components/Modals/ModalSignUpConfirmation";
import signUpCognito from "../../utils/authentication/signUpCognito";

class SignUp extends Component {
  constructor(props){
    super(props);
    this.state = {
      email: "",
      password1: "",
      password2: "",
      user: false,
      modal: false
    }
    this.handleInputs = this.handleInputs.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
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
          modal: true
        });
      }
    });
  }

  toggleModal = () => {
    this.setState(prevState => {
      return {modal: !prevState.modal}
    });
  };

  render() {
    return (
      <>
        <FormUserSignUp
          handleInputs={this.handleInputs}
          handleSubmit={this.handleSubmit}
        />
        <ModalSignUpConfirmation
          isOpen={this.state.modal}
          toggle={this.toggleModal}
          user={this.state.user}
          email={this.state.email}
          className="modal-lg"
        />
      </>
    );
  }
}

export default SignUp;
