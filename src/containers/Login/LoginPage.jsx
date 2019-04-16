import React, { Component } from "react";
import FormLogin from "../../components/Forms/FormLogin";

class LoginPage extends Component {
  constructor(props){
    super(props);
    this.state = {
      username: "",
      password: ""
    }
    this.handleLoginInputs = this.handleLoginInputs.bind(this);
  }

  handleLoginInputs(event){
    this.setState({
      [event.target.name]: event.target.value
    });
  }
  render() {
    return (
      <FormLogin
        handleChange={this.handleLoginInputs}
      />
    );
  }
}

export default LoginPage;
