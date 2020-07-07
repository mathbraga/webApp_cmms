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
import cookieAuth from "../../utils/authentication/cookieAuth";

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
  
  componentWillMount(){
    cookieAuth().then(() => { // cookie = true
        this.setUser();
    })
    .catch((err) => { // no cookie
      console.log(err);
      this.setNoUser();
    })
  }

  setUser = () => {
    this.setState({ user: true });
  }

  setNoUser = () => {
    this.setState({ user: false });
  }

  loading = () => (
    <div className="animated fadeIn pt-1 text-center">Carregando...</div>
  );

  render() {
    return (
      <div className="app">
        <AppHeader fixed>
          <Suspense fallback={this.loading}>
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
    );
  }
}

export default MainPage;
