import React, { Component } from "react";
import {
  Card,
  CardBody,
  Col,
  Row,
  ButtonDropdown,
  DropdownToggle,
  DropdownItem,
  DropdownMenu,
  CardHeader
} from "reactstrap";

class Dropdown extends Component {
  constructor(props) {
    super(props);
    this.state = {
      dropdownOpen: false
    };
  }

  toggle = () => {
    const newState = !this.state.dropdownOpen;
    this.setState({
      dropdownOpen: newState
    });
  };

  render() {
    const { selectedItem, dropdownItems, changeItem } = this.props;
    console.log("ChangeItem:");
    console.log(changeItem);

    return (
      <ButtonDropdown
        isOpen={this.state.dropdownOpen}
        toggle={() => {
          this.toggle();
        }}
      >
        <DropdownToggle caret size="sm">
          {selectedItem}
        </DropdownToggle>
        <DropdownMenu className="dropdown-menu">
          {Object.keys(dropdownItems).map(itemID => (
            <DropdownItem onClick={() => changeItem(itemID)}>
              {dropdownItems[itemID]}
            </DropdownItem>
          ))}
        </DropdownMenu>
      </ButtonDropdown>
    );
  }
}

export default Dropdown;
