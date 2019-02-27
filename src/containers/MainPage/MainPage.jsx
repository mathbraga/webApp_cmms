import React, { Component, Suspense } from "react";
import { Redirect, Route, Switch } from "react-router-dom";
import { Container } from "reactstrap";

import {
  AppAside,
  AppBreadcrumb,
  AppFooter,
  AppHeader,
  AppSidebar,
  AppSidebarFooter,
  AppSidebarForm,
  AppSidebarHeader,
  AppSidebarMinimizer,
  AppSidebarNav
} from "@coreui/react";

const MainHeader = React.lazy(() => import("./MainHeader"));

class MainPage extends Component {
  loading = () => (
    <div className="animated fadeIn pt-1 text-center">Loading...</div>
  );

  render() {
    return (
      <div>
        <AppHeader fixed>
          <Suspense fallback={this.loading()}>
            <MainHeader />
          </Suspense>
        </AppHeader>
      </div>
    );
  }
}

export default MainPage;
