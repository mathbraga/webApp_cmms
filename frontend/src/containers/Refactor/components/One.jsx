import React, { Component } from "react";
import { Nav, Navbar, NavItem, NavbarBrand, NavLink, Container, Row, Col, Card, CardHeader, CardBody, Table } from 'reactstrap';

class One extends Component {
  constructor(props) {
    super(props);
  }

  render() {

    const { one } = this.props;

    return (
      <div className="animated fadeIn">
        <Row>
          <Col xs="auto">
            <Card>
              <CardHeader>
                <Navbar color="light" light expand="xs">
                  <NavbarBrand >{one.title}</NavbarBrand>
                  <Nav navbar>
                    {one.tabs.map(tab => (
                      <NavItem>
                        <NavLink href="#">
                          <strong>{tab.label}</strong>
                        </NavLink>
                      </NavItem>
                    ))}
                  </Nav>
                </Navbar>
              </CardHeader>
              <CardBody>
                <Container>
                  <Row>
                    <Col>
                      <p>Conteúdo da página</p>
                    </Col>
                  </Row>
                </Container>
              </CardBody>
            </Card>
          </Col>
        </Row>
      </div>
    );
  }
}

export default One;
