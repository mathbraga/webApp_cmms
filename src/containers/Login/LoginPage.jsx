import React, { Component } from "react";
import FormLogin from "../../components/Forms/FormLogin";
import userPoolInit from "../../utils/userPoolInit";
import loginCognito from "../../utils/loginCognito";

class LoginPage extends Component {
  constructor(props){
    super(props);
    const userPool = userPoolInit();
    this.state = {
      userPool: userPool,
      Username: "",
      Password: ""
    }
    this.handleLoginInputs = this.handleLoginInputs.bind(this);
    this.handleLoginSubmit = this.handleLoginSubmit.bind(this);
  }

  handleLoginInputs(event){
    this.setState({
      [event.target.name]: event.target.value
    });
  }

  handleLoginSubmit(event){
    event.preventDefault();
    loginCognito();
  }

  render() {
    return (
      <FormLogin
        handleLoginInputs={this.handleLoginInputs}
        handleLoginSubmit={this.handleLoginSubmit}
      />
    );
  }
}

export default LoginPage;
