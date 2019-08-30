import React, { Component } from 'react';
import {
  FormGroup,
  Label,
  Input,
} from 'reactstrap';

import "./InputWithDropdown.css";

class InputWithDropdown extends Component {
  constructor(props) {
    super(props);
    this.state = {
      departmentInputValue: '',
      isDropdownOpen: false,
      hoveredItem: 0,
      departmentValues: [],
    }
    this.onChangeInputDepartment = this.onChangeInputDepartment.bind(this);
    this.toggleDropdown = this.toggleDropdown.bind(this);
    this.onHoverItem = this.onHoverItem.bind(this);
    this.onKeyDownInput = this.onKeyDownInput.bind(this);
    this.onRemoveItemFromList = this.onRemoveItemFromList.bind(this);
    this.arrayItems = {};
  }

  onChangeInputDepartment(event) {
    this.containerScroll.scrollTo(0, 0);
    this.setState({
      departmentInputValue: event.target.value,
      hoveredItem: 0,
    });
  }

  toggleDropdown(isDropdownOpen) {
    this.setState({
      isDropdownOpen
    });
  }

  onHoverItem(index) {
    this.setState({
      hoveredItem: index,
    });
  }

  onKeyDownInput = (filteredList) => (event) => {
    const { hoveredItem } = this.state;
    const lengthList = filteredList.length;
    console.log("KeyCode:");
    console.log(event.keyCode);
    switch (event.keyCode) {
      case 40:
        this.setState(prevState => {
          if (prevState.hoveredItem === lengthList - 1) { return; }
          this.arrayItems[filteredList[hoveredItem + 1].id]
            .scrollIntoViewIfNeeded(false, { behavior: 'smooth' });
          return {
            hoveredItem: prevState.hoveredItem + 1
          }
        });
        break;
      case 38:
        this.setState(prevState => {
          if (prevState.hoveredItem === 0) { return; }
          this.arrayItems[filteredList[hoveredItem - 1].id]
            .scrollIntoViewIfNeeded(true, { behavior: 'smooth' });
          return {
            hoveredItem: prevState.hoveredItem - 1
          }
        });
        break;
      case 13:
        this.setState(prevState => {
          const newListofDepartments =
            [...prevState.departmentValues, filteredList[prevState.hoveredItem]]
          return {
            departmentValues: newListofDepartments,
          };
        })
        break;
    }
  }

  onRemoveItemFromList(id) {
    this.setState(prevState => {
      const newList = prevState.departmentValues.filter(item =>
        item.id !== id);
      console.log(newList);
      return {
        departmentValues: newList,
      };
    });
  }

  render() {
    const { label, placeholder, listDropdown } = this.props;
    const { departmentInputValue, isDropdownOpen, hoveredItem, departmentValues } = this.state;
    const filteredList = listDropdown.filter((item) =>
      (
        item.name.toLowerCase().includes(departmentInputValue.toLowerCase())
        && !departmentValues.some(selectedItem => selectedItem.id === item.id)
      ));
    return (
      <FormGroup className={'dropdown-container'}>
        <Label htmlFor="department">{label}</Label>
        {departmentValues.map(item => (
          <div className='container-selected-items'>
            <Input
              type="text"
              value={item.name}
              disabled
              className='selected-items'
            />
            <div className='remove-image'>
              <img
                src={require("../../assets/icons/remove_icon.png")}
                alt="Remove"
                onClick={() => { this.onRemoveItemFromList(item.id) }}
              />
            </div>
          </div>
        ))}
        <Input
          type="text"
          id="department"
          style={departmentValues.length === 0 ? {} : { marginTop: "10px" }}
          value={departmentInputValue}
          placeholder={placeholder}
          onChange={this.onChangeInputDepartment}
          onFocus={() => this.toggleDropdown(true)}
          onBlur={() => this.toggleDropdown(false)}
          onKeyDown={this.onKeyDownInput(filteredList)}
        />
        {isDropdownOpen && (
          <div
            className="dropdown-input"
            ref={(el) => { this.containerScroll = el }}
          >
            <ul>
              {filteredList.map((item, index) => (
                <li
                  id={item.id}
                  onMouseOver={() => this.onHoverItem(index)}
                  className={filteredList[hoveredItem].id === item.id ? 'active' : ''}
                  ref={(el) => this.arrayItems[item.id] = el}
                >{item.name}</li>
              ))}
            </ul>
          </div>
        )}
      </FormGroup>
    );
  }
}

export default InputWithDropdown;