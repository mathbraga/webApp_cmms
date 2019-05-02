import React, { Component } from "react";
import { Route, Redirect } from "react-router-dom";
import logoutCognito from "../../utils/authentication/logoutCognito";

class Logout extends Component {
  constructor(props){
    super(props);
    if(window.sessionStorage.getItem("email") !== null){
      logoutCognito(window.sessionStorage.email)
    }
  }

  render() {
    return (
      <>
        <Route exact path="/logout" render={() => (
            <Redirect to="/login"/>
        )}/>
      </>
    );
  }
}

export default Logout;