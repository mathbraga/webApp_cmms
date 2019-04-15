import React, { Component } from "react";
import { Link } from "react-router-dom";
import {
  Nav,
  NavItem,
  } from "reactstrap";

import {
  AppNavbarBrand,
  AppSidebarToggler
} from "@coreui/react";
import logo from "../../assets/img/brand/logo.svg";
import sygnet from "../../assets/img/brand/sygnet.svg";

class MainHeader extends Component {
  render() {
    return (
      <React.Fragment>
        <AppSidebarToggler className="d-lg-none" display="md" mobile />
        <AppNavbarBrand
          full={{ src: logo, height: 35, alt: "Senado Logo" }}
          minimized={{ src: sygnet, width: 30, height: 30, alt: "Senado Logo" }}
        />
        <AppSidebarToggler className="d-md-down-none" display="lg" />

        <Nav className="d-md-down-none" navbar>
          <NavItem className="px-3">
            <Link to="/" className="nav-link">
              Início
            </Link>
          </NavItem>
        </Nav>

        <Nav className="ml-auto" navbar />
      </React.Fragment>
    );
  }
}

export default MainHeader;
