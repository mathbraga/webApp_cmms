import React, { Component } from "react";
import { Link, withRouter } from "react-router-dom";
import {
  Nav,
  NavItem,
  Dropdown,
  DropdownItem,
  DropdownToggle,
  DropdownMenu
} from "reactstrap";

import {
  AppNavbarBrand,
  AppSidebarToggler,
  AppHeaderDropdown
} from "@coreui/react";

import logo from "../../assets/img/brand/logo.svg";
import sygnet from "../../assets/img/brand/sygnet.svg";
import { logout } from "../../redux/actions";
import { connect } from "react-redux";

class MainHeader extends Component {
  constructor(props) {
    super(props);
    this.handleLogout = this.handleLogout.bind(this);
    this.handleDropdownClick = this.handleDropdownClick.bind(this);
    this.state = {
      dropdownOpen: false,
    }
  }

  handleLogout(event) {
    event.preventDefault();
    this.props.dispatch(logout(this.props.history));
  }

  handleDropdownClick(event) {
    this.setState(prevState => ({
      dropdownOpen: !prevState.dropdownOpen
    }));
  }

  render() {
    return (
      <React.Fragment>
        <AppSidebarToggler className="d-lg-none" display="md" mobile />
        <AppNavbarBrand
          full={{ src: logo, height: 35, alt: "Senado Logo" }}
          minimized={{ src: sygnet, width: 30, height: 30, alt: "Senado Logo" }}
        />
        <AppSidebarToggler className="d-md-down-none" display="lg" />
        <Nav className="d-md-down-none ml-auto" navbar>
          {window.localStorage.getItem('session') === null ? (
            <React.Fragment>
              <NavItem className="px-3">
                <Link to="/cadastro" className="nav-link">
                  Cadastro
                </Link>
              </NavItem>
              <NavItem className="px-3">
                <Link to="/login" className="nav-link">
                  Login
                </Link>
              </NavItem>
            </React.Fragment>

          ) : (

            <Dropdown
              direction="down"
              toggle={this.handleDropdownClick}
              isOpen={this.state.dropdownOpen}
            >
              <DropdownToggle nav className="px-3">
                  <i className="fa fa-user-circle" />
                  {" " + window.localStorage.getItem('session')}
              </DropdownToggle>
              <DropdownMenu right style={{ right: 'auto' }}>
                  <DropdownItem onClick={this.props.history.push('/perfil')}><i className="fa fa-user"></i>Perfil</DropdownItem>
                  {/* <DropdownItem><i className="fa fa-wrench"></i>Configurações</DropdownItem> */}
                  <DropdownItem onClick={this.handleLogout}><i className="fa fa-lock"></i> Logout</DropdownItem>
              </DropdownMenu>
            </Dropdown>
          )}
        </Nav>
      </React.Fragment>
    );
  }
}

const mapStateToProps = storeState => {
  let email = storeState.auth.email;
  return {
    email
  }
}

export default connect(mapStateToProps)(withRouter(MainHeader));
