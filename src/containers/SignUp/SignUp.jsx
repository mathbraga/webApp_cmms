import React, { Component } from "react";
import FormUserSignUp from "../../components/Forms/FormUserSignUp";
import signUpCognito from "../../utils/authentication/signUpCognito";

class SignUp extends Component {
  constructor(props){
    super(props);
    this.state = {
      email: "",
      password1: "",
      password2: ""
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
    let signUpResult = signUpCognito(this.state.email, this.state.password1, this.state.password2);
    
  }

  render() {
    return (
      <>
        <FormUserSignUp
          handleInputs={this.handleInputs}
          handleSubmit={this.handleSubmit}
        />
        {/* <ModalSignUpConfirmation/> */}
      </>
    );
  }
}

export default SignUp;
