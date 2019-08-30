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
      departmentValue: '',
      isDropdownOpen: false,
    }
    this.onChangeDepartment = this.onChangeDepartment.bind(this);
    this.toggleDropdown = this.toggleDropdown.bind(this);
  }

  onChangeDepartment(event) {
    this.setState({
      departmentValue: event.target.value,
    });
  }

  toggleDropdown(isDropdownOpen) {
    this.setState({
      isDropdownOpen
    });
  }

  render() {
    const { label, placeholder, listDropdown } = this.props;
    const { departmentValue, isDropdownOpen } = this.state;
    return (
      <FormGroup className={'dropdown-container'}>
        <Label htmlFor="department">{label}</Label>
        <Input
          type="text"
          id="department"
          value={departmentValue}
          placeholder={placeholder}
          onChange={this.onChangeDepartment}
          onFocus={() => this.toggleDropdown(true)}
          onBlur={() => this.toggleDropdown(false)}
        />
        {isDropdownOpen && (
          <div className="dropdown-input">
            <ul>
              {listDropdown.map((item) => (
                <li>{item}</li>
              ))}
            </ul>
          </div>
        )}
      </FormGroup>
    );
  }
}

export default InputWithDropdown;