import React, { Component } from "react";
import { ButtonToolbar, ButtonGroup, UncontrolledCollapse, Button, Nav, Navbar, NavItem, NavbarBrand, NavLink, Container, Row, Col, Card, CardHeader, CardBody, Table } from 'reactstrap';

class One extends Component {
  constructor(props) {
    super(props);
    this.state = {
      activeTab: 'details',
    };
    this.changeTab = this.changeTab.bind(this);
  }

  changeTab(event){
    this.setState({ activeTab: event.target.name });
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
                  <Nav>
                    {one.tabs.map(tab => (
                      <NavItem key={tab.tabName}>
                        <Button
                          outline={!(this.state.activeTab === tab.tabName)}
                          color={this.state.activeTab === tab.tabName ? 'dark' : 'link'}
                          name={tab.tabName}
                          onClick={this.changeTab}
                          disabled={this.state.activeTab === tab.tabName}
                        >{tab.label}
                        </Button>
                      </NavItem>
                    ))}
                  </Nav>
                </Navbar>
              </CardHeader>
              <CardBody>
                <Container>
                  <Row>
                    <Col>
                      {one.tabs.map(tab => (
                        <React.Fragment key={tab.tabName}>
                          {this.state.activeTab === tab.tabName ? (
                            <Table>
                              {!tab.table.noHead ? (
                                <thead>
                                  <tr>
                                    {tab.table.head.map(column => (
                                      <th key={column.field}>
                                        {column.label}
                                      </th>
                                    ))}
                                  </tr>
                                </thead>
                              ) : (
                                null
                              )}  
                              <tbody>
                                {tab.table.body.map((row, i) => (
                                  <tr key={i}>
                                    {tab.table.head.map((column, j) => (
                                      <React.Fragment>
                                        {j === 0 && tab.tabName === 'details' ? (
                                          <td key={j}>
                                            <strong>{row[column.field]}</strong>
                                        </td>
                                        ) : (
                                          <td key={j}>
                                            {row[column.field]}
                                          </td>
                                        )}
                                      </React.Fragment>
                                    ))}
                                  </tr>
                                ))}
                              </tbody>
                            </Table>
                          ) : (
                            null
                          )}
                        </React.Fragment>
                      ))}
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
