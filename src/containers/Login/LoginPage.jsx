import React, { Component } from "react";
import FormUser from "../../components/Forms/FormUser";
// import userPoolInit from "../../utils/userPoolInit";
import loginCognito from "../../utils/loginCognito";
import * as AWS from 'aws-sdk/global';


class LoginPage extends Component {
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
    loginCognito(this.state.Username, this.state.Password);
  }

  render() {
    return (
      <FormUser
        handleInputs={this.handleInputs}
        handleSubmit={this.handleSubmit}
        title="Login"
      />
    );
  }
}

export default LoginPage;
