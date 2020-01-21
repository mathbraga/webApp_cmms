import React, { Component } from 'react';
import './TabContainer';
import {
  Nav,
  NavItem,
  NavLink,
  TabContent,
  TabPane
} from 'reactstrap';

const propsTest = {
  id: 'facility1',
  tabs: [
    { id: 'info', title: 'Informação', element: <h1>Hi</h1> }
  ]
}

export default class TabContainer extends Component {
  constructor(props) {
    super(props);
    this.state = {
      tabSelected: this.props.tabs[0].id,
    }

    this.handleClickOnNav = this.handleClickOnNav.bind(this);
  }

  handleClickOnNav(event) {
    this.setState({ tabSelected: event.target.name });
  }

  render() {
    const { tabs } = this.props;
    const { tabSelected } = this.state;
    return (
      <div style={{ margin: "40px 20px 20px 20px", width: "96%" }}>
        <Nav tabs>
          {
            tabs.map((tab) => (
              <NavItem>
                <NavLink name={tab.id} onClick={this.handleClickOnNav} active={tabSelected === tab.id} >{tab.title}</NavLink>
              </NavItem>
            ))
          }
        </Nav>
        <TabContent activeTab={tabSelected} style={{ width: "100%" }}>
          {
            tabs.map((tab) => (
              <TabPane tabId={tab.id} style={{ width: "100%" }}>
                {tab.element}
              </TabPane>
            ))
          }
        </TabContent>
      </div>
    );
  }
}