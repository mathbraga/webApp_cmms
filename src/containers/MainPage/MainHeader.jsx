import React, { Component } from "react";
import { Link } from "react-router-dom";
import {
  Nav,
  NavItem,
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
import { endSession } from "../../redux/actions";
import { connect } from "react-redux";
import { bindActionCreators } from "redux";

class MainHeader extends Component {
  constructor(props){
    super(props);
    this.handleLogout = this.handleLogout.bind(this);
  }
  
  handleLogout(event){
    event.preventDefault();
    this.props.endSession();
    this.props.history.push("/login");
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

        <Nav className="d-md-down-none" navbar>

          {/* <NavItem className="px-3">
            <Link to="/" className="nav-link">
              Início
            </Link>
          </NavItem> */}

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

          {/* <NavItem className="px-3">
            <Link to="/logout" className="nav-link">
              Logout
            </Link>
          </NavItem> */}
          
          <AppHeaderDropdown direction="down">
          <DropdownToggle nav>
              <i className="fa fa-user-circle"/>
            </DropdownToggle>
            <DropdownMenu right style={{ right: 'auto' }}>
              {/* <DropdownItem header tag="div" className="text-center"><strong>Account</strong></DropdownItem> */}
              {/* <DropdownItem><i className="fa fa-bell-o"></i> Updates<Badge color="info">42</Badge></DropdownItem> */}
              {/* <DropdownItem><i className="fa fa-envelope-o"></i> Messages<Badge color="success">42</Badge></DropdownItem> */}
              {/* <DropdownItem><i className="fa fa-tasks"></i> Tasks<Badge color="danger">42</Badge></DropdownItem> */}
              {/* <DropdownItem><i className="fa fa-comments"></i> Comments<Badge color="warning">42</Badge></DropdownItem> */}
              {/* <DropdownItem header tag="div" className="text-center"><strong>Settings</strong></DropdownItem> */}
              <DropdownItem><i className="fa fa-user"></i>Perfil</DropdownItem>
              <DropdownItem><i className="fa fa-wrench"></i>Configurações</DropdownItem>
              {/* <DropdownItem><i className="fa fa-usd"></i>Payments<Badge color="secondary">42</Badge></DropdownItem> */}
              {/* <DropdownItem><i className="fa fa-file"></i>Projects<Badge color="primary">42</Badge></DropdownItem> */}
              {/* <DropdownItem divider /> */}
              {/* <DropdownItem><i className="fa fa-shield"></i> Lock Account</DropdownItem> */}
              <DropdownItem onClick={this.handleLogout}><i className="fa fa-lock"></i> Logout</DropdownItem>
            </DropdownMenu>

          </AppHeaderDropdown>

        </Nav>

        <Nav className="ml-auto" navbar />
      </React.Fragment>
    );
  }
}

function mapDispatchToProps(dispatch) {
  return bindActionCreators({ endSession }, dispatch)
}

export default connect(
  null,
  mapDispatchToProps
)(MainHeader);
