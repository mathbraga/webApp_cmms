import React, { Component } from 'react';
import {
  FormGroup,
  Label,
  Input,
} from 'reactstrap';

import "./InputWithDropdown.css";

const updateDepartmentValues = (filteredList) => (prevState) => {
  if (prevState.hoveredItem < 0 || prevState.hoveredItem >= filteredList.length) {
    return {
      departmentInputValue: "",
    };
  }
  const newListofDepartments = [...prevState.departmentValues, filteredList[prevState.hoveredItem]];
  const newHoveredItem = prevState.hoveredItem === 0 ? 0 : (prevState.hoveredItem - 1);
  return {
    departmentValues: newListofDepartments,
    hoveredItem: newHoveredItem,
    departmentInputValue: "",
  };
};

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
    this.onClickItem = this.onClickItem.bind(this);
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
        this.inputDrop.blur();
        this.setState(updateDepartmentValues(filteredList));
        break;
    }
  }

  onRemoveItemFromList(id) {
    this.setState(prevState => {
      const newList = prevState.departmentValues.filter(item =>
        item.id !== id);
      return {
        departmentValues: newList,
        hoveredItem: 0,
      };
    });
  }

  onClickItem = (filteredList) => () => {
    this.setState(updateDepartmentValues(filteredList));
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
          autoComplete="off"
          id="department"
          style={departmentValues.length === 0 ? {} : { marginTop: "10px" }}
          value={departmentInputValue}
          placeholder={placeholder}
          onChange={this.onChangeInputDepartment}
          onFocus={() => this.toggleDropdown(true)}
          onBlur={() => this.toggleDropdown(false)}
          onKeyDown={this.onKeyDownInput(filteredList)}
          innerRef={(el) => { this.inputDrop = el; }}
        />
        {isDropdownOpen && (
          <div
            className="dropdown-input"
            ref={(el) => { this.containerScroll = el }}
          >
            <ul>
              {filteredList.map((item, index) => (
                <li
                  key={item.id}
                  id={item.id}
                  onMouseOver={() => this.onHoverItem(index)}
                  onMouseDown={this.onClickItem(filteredList)}
                  className={filteredList[hoveredItem].id === item.id ? 'active' : ''}
                  ref={(el) => this.arrayItems[item.id] = el}
                >{item.name}</li>
              ), this)}
            </ul>
          </div>
        )}
      </FormGroup>
    );
  }
}

export default InputWithDropdown;