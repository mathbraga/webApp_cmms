import React, { Component } from "react";
import FormUserSignUp from "../../components/Forms/FormUserSignUp";
import signUpCognito from "../../utils/authentication/signUpCognito";

class SignUp extends Component {
  constructor(props){
    super(props);
    this.state = {
      Email: "",
      Password1: "",
      Password2: ""
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
    signUpCognito(this.state.Email, this.state.Password1, this.state.Password2);
  }

  render() {
    return (
      <FormUserSignUp
        handleInputs={this.handleInputs}
        handleSubmit={this.handleSubmit}
      />
    );
  }
}

export default SignUp;
