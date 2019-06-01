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
import { logout } from "../../redux/actions";
import { connect } from "react-redux";

class MainHeader extends Component {
  constructor(props){
    super(props);
    this.handleLogout = this.handleLogout.bind(this);
  }
  
  handleLogout(event){
    event.preventDefault();
    this.props.dispatch(logout());
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

          {!this.props.session &&
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
          }
          
          <AppHeaderDropdown direction="down">
            
            {this.props.session &&
              <React.Fragment>
                <DropdownToggle nav>
                  <i className="fa fa-user-circle"/>
                  {" " + this.props.session.idToken.payload.email}
                </DropdownToggle>
                
                <DropdownMenu right style={{ right: 'auto' }}>
                  <DropdownItem><i className="fa fa-user"></i>Perfil</DropdownItem>
                  <DropdownItem><i className="fa fa-wrench"></i>Configurações</DropdownItem>
                  <DropdownItem onClick={this.handleLogout}><i className="fa fa-lock"></i> Logout</DropdownItem>
                </DropdownMenu>
              </React.Fragment>
            }
            

          </AppHeaderDropdown>

        </Nav>

        <Nav className="ml-auto" navbar />
      </React.Fragment>
    );
  }
}

const mapStateToProps = storeState => {
  let session = storeState.auth.session;
  return {
    session
  }
}

export default connect(mapStateToProps)(MainHeader);
