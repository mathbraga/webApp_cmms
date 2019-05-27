import React, { Component, Suspense } from "react";
import { Redirect, Route, Switch } from "react-router-dom";
import { Container } from "reactstrap";
import {
  AppBreadcrumb,
  AppHeader,
  AppSidebar,
  AppSidebarFooter,
  AppSidebarForm,
  AppSidebarHeader,
  AppSidebarMinimizer,
  AppSidebarNav
} from "@coreui/react";

// sidebar nav config
import navigation from "../../_nav";
// routes config
import routes from "../../routes";

import Login from "../Authentication/Login";
import loginCognito from "../../utils/authentication/loginCognito";
import logoutCognito from "../../utils/authentication/logoutCognito";

const MainHeader = React.lazy(() => import("./MainHeader"));

class MainPage extends Component {

  constructor(props){
    super(props);
    this.state = {
      email: "",
      password: "",
      loggedIn: false,
      alertVisible: false
    }
    this.handleLoginInputs = this.handleLoginInputs.bind(this);
    this.handleLoginSubmit = this.handleLoginSubmit.bind(this);
    this.handleAlertDismiss = this.handleAlertDismiss.bind(this);
    this.handleLogout = this.handleLogout.bind(this);
  }

  loading = () => (
    <div className="animated fadeIn pt-1 text-center">Carregando...</div>
  );

  handleLoginInputs(event){
    this.setState({
      [event.target.name]: event.target.value
    });
  }

  handleLoginSubmit(event){
    event.preventDefault();
    loginCognito(this.state.email, this.state.password).then(userSession => {
      if(userSession){
        this.setState({
          loggedIn: userSession,
          alertVisible: false,
          email: "",
          password: "",

        });
      } else {
        this.setState({
          alertVisible: true,
          email: "",
          password: ""
        });
      }
    }).catch(() => {
      this.setState({
        alertVisible: true,
        email: "",
        password: ""
      });
    });
  }

  handleAlertDismiss() {
    this.setState({
      alertVisible: false
    });
  }

  handleLogout(){
    if(window.sessionStorage.getItem("email") !== null){
      logoutCognito(window.sessionStorage.getItem("email"));
    }
    this.props.history.push("/login");
  }


  render() {
    return (
      <div className="app">
        <AppHeader fixed>
          <Suspense fallback={this.loading()}>
            <MainHeader 
              handleLogout={this.handleLogout}
            />
          </Suspense>
        </AppHeader>
        <div className="app-body">
          <AppSidebar fixed display="lg">
            <AppSidebarHeader />
            <AppSidebarForm />
            <Suspense>
              <AppSidebarNav navConfig={navigation} {...this.props} />
            </Suspense>
            <AppSidebarFooter />
            <AppSidebarMinimizer />
          </AppSidebar>
          <main className="main">
            <AppBreadcrumb appRoutes={routes} />
            <Container fluid>
              <Suspense fallback={this.loading()}>
                <Switch>

                  <Route path="/login" render={(routerProps) =>(
                    <Login
                      {...routerProps}
                      loggedIn={this.state.loggedIn}
                      handleLoginInputs={this.handleLoginInputs}
                      handleLoginSubmit={this.handleLoginSubmit}
                      handleAlertDismiss={this.handleAlertDismiss}
                      alertVisible={this.state.alertVisible}
                    />
                  )}/>

                  {routes.map((route, idx) => {
                    return route.component ? (
                      <Route
                        key={idx}
                        path={route.path}
                        exact={route.exact}
                        name={route.name}
                        render={routerProps => <route.component {...routerProps} {...route.options}/>}
                      />
                    ) : null;
                  })}
                  <Redirect from="/" to={{pathname:"/painel", state: this.props.location.state}}/>
                </Switch>
              </Suspense>
            </Container>
          </main>
        </div>
      </div>
    );
  }
}

export default MainPage;
