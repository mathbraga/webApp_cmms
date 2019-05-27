import React, { Component } from "react";
import { Redirect } from "react-router-dom";
import FormUserLogin from "../../components/Forms/FormUserLogin";
import loginCognito from "../../utils/authentication/loginCognito";
import { Alert } from "reactstrap";

class Login extends Component {
  constructor(props){
    super(props);
  }

  render() {
    return (
      <React.Fragment>
        <FormUserLogin
          handleInputs={this.props.handleLoginInputs}
          handleSubmit={this.props.handleLoginSubmit}
        />

        {this.props.loggedIn &&
          <Redirect to={{pathname: "/", state: {userSession: this.props.loggedIn}}}/>
        }

        <Alert color="danger" isOpen={this.props.alertVisible} toggle={this.props.handleAlertDismiss}>
          Login falhou. Tente novamente.
        </Alert>

      </React.Fragment>
    );
  }
}

export default Login;
