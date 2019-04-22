import React, { Component } from "react";
import FormLogin from "../../components/Forms/FormLogin";
// import userPoolInit from "../../utils/userPoolInit";
import signUpCognito from "../../utils/signUpCognito";
import * as AWS from 'aws-sdk/global';


class SignUpPage extends Component {
  constructor(props){
    super(props);
    this.state = {
      Username: "",
      Password: ""
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
    signUpCognito(this.state.Username, this.state.Password);
  }

  render() {
    return (
      <FormLogin
        handleInputs={this.handleInputs}
        handleSubmit={this.handleSubmit}
      />
    );
  }
}

export default SignUpPage;
