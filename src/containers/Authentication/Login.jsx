import React, { Component } from "react";
import { Route, Redirect } from "react-router-dom";
import FormUserLogin from "../../components/Forms/FormUserLogin";
import loginCognito from "../../utils/authentication/loginCognito";
import { Alert } from "reactstrap";

class Login extends Component {
  constructor(props){
    super(props);
    this.state = {
      email: "",
      password: "",
      loggedIn: false,
      alertVisible: false
    }
    this.handleInputs = this.handleInputs.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
    this.onAlertDismiss = this.onAlertDismiss.bind(this);
  }

  handleInputs(event){
    this.setState({
      [event.target.name]: event.target.value
    });
  }

  handleSubmit(event){
    event.preventDefault();
    loginCognito(this.state.email, this.state.password).then(loggedIn => {
      if(loggedIn){
        this.setState({
          loggedIn: loggedIn,
          alertVisible: false
        });
      } else {
        this.setState({
          alertVisible: true
        });
      }
    }).catch(() => {
      this.setState({
        alertVisible: true
      });
    });
  }

  onAlertDismiss() {
    this.setState({
      alertVisible: false
    });
  }

  render() {
    return (
      <React.Fragment>
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

        <Alert color="danger" isOpen={this.state.alertVisible} toggle={this.onAlertDismiss}>
          Login falhou. Tente novamente.
        </Alert>

      </React.Fragment>
    );
  }
}

export default Login;
