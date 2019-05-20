import React, { Component } from "react";
import { Route, Redirect } from "react-router-dom";
import FormUserLogin from "../../components/Forms/FormUserLogin";
import loginCognito from "../../utils/authentication/loginCognito";

class Login extends Component {
  constructor(props){
    super(props);
    this.state = {
      email: "",
      password: "",
      loggedIn: false
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
    loginCognito(this.state.email, this.state.password).then(loggedIn => {
      this.setState({loggedIn: loggedIn});
    });
  }

  render() {
    return (
      <>
        <FormUserLogin
          handleInputs={this.handleInputs}
          handleSubmit={this.handleSubmit}
        />

        <Route exact path="/login" render={() => (
          this.state.loggedIn ? (
            <Redirect to="/dashboard"/>
          ) : (
            <Redirect to="/login"/>
          )
        )}/>
      </>
    );
  }
}

export default Login;
