import React, { Component } from "react";
import { Link } from "react-router-dom";
import {
  Badge,
  DropdownItem,
  DropdownMenu,
  DropdownToggle,
  Nav,
  NavItem,
  NavLink
} from "reactstrap";
import PropTypes from "prop-types";

import {
  AppAsideToggler,
  AppHeaderDropdown,
  AppNavbarBrand,
  AppSidebarToggler
} from "@coreui/react";
import logo from "../../assets/img/brand/senado-federal-logo.svg";
import sygnet from "../../assets/img/brand/senado-federal-logo.svg";

class MainHeader extends Component {
  render() {
    console.log("Ok");
    return (
      <React.Fragment>
        <AppSidebarToggler className="d-lg-none" display="md" mobile />
        <AppNavbarBrand
          full={{ src: logo, width: 89, height: 25, alt: "Senado Logo" }}
          minimized={{ src: sygnet, width: 30, height: 30, alt: "Senado Logo" }}
        />
        <AppSidebarToggler className="d-md-down-none" display="lg" />

        <Nav className="d-md-down-none" navbar>
          <NavItem className="px-3">
            <Link to="/" className="nav-link">
              Link 01
            </Link>
          </NavItem>
          <NavItem className="px-3">
            <Link to="/users">Link 02</Link>
          </NavItem>
          <NavItem className="px-3">
            <NavLink href="#">Link 03</NavLink>
          </NavItem>
        </Nav>

        <Nav className="ml-auto" navbar />
      </React.Fragment>
    );
  }
}

export default MainHeader;
