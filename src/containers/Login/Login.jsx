import React, { Component } from "react";
import FormUserLogin from "../../components/Forms/FormUserLogin";
import loginCognito from "../../utils/authentication/loginCognito";

class Login extends Component {
  constructor(props){
    super(props);
    this.state = {
      email: "",
      password: ""
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
    loginCognito(this.state.email, this.state.password);
  }

  render() {
    return (
      <FormUserLogin
        handleInputs={this.handleInputs}
        handleSubmit={this.handleSubmit}
      />
    );
  }
}

export default Login;
