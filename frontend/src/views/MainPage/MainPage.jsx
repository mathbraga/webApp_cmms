import React, { Component, Suspense } from "react";
import { Redirect, Route, Switch } from "react-router-dom";
import { Container } from "reactstrap";
import {
  // AppBreadcrumb,
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

import AuthContext from "../../utils/authentication/authContext"

const MainHeader = React.lazy(() => import("./MainHeader"));
const Dashboard = React.lazy(() => import("../Dashboard"));
const Login = React.lazy(() => import("../Authentication/Login"));

class MainPage extends Component {
  constructor(props){
    super(props);
    this.state = {
      user: null
    }
  }

  loginFetch = (email, password) => {
    return new Promise((resolve, reject) => {
    
      fetch(process.env.REACT_APP_SERVER_URL + process.env.REACT_APP_LOGIN_PATH, {
        method: 'POST',
        credentials: 'include',
        body: JSON.stringify({
          email: email,
          password: password
        }),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      })
        .then(r => {
          if(r.status === 200){
            resolve(r.json());
          } else {
            reject();
          }
        })
        .catch(error => {
          alert(error);
          reject("Erro no login.")
        });
    });
  }
  
  loading = () => (
    <div className="animated fadeIn pt-1 text-center">Carregando...</div>
  );

  render() {
    return (
      <AuthContext.Provider value={{ user: this.state.user, loginFetch: this.loginFetch }}>
        <div className="app">
          <AppHeader fixed>
            <Suspense fallback={this.loading()}>
              <MainHeader/>
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
              {/* <AppBreadcrumb appRoutes={routes} /> */}
              <Container fluid className="pt-4">
                <Suspense fallback={this.loading()}>
                  <Switch>
                    {this.state.user && routes.map((route, idx) => {
                      return route.component ? (
                        <Route
                          key={idx}
                          path={route.path}
                          exact={route.exact}
                          name={route.name}
                          render={routerProps => <route.component {...routerProps} {...route.props}/>}
                        />
                      ) : null;
                    })}
                    {!this.state.user && <Route path="/painel" name="Painel" component={Dashboard}/>}
                    {!this.state.user && <Route path="/login" name="Login" component={Login}/>}
                    {!this.state.user && <Redirect from="/" to={{ pathname: "/login" }}/>}
                    {this.state.user && <Redirect from="/" to={{ pathname: "/painel" }}/>}
                  </Switch>
                </Suspense>
              </Container>
            </main>
          </div>
        </div>
      </AuthContext.Provider>
    );
  }
}

export default MainPage;
