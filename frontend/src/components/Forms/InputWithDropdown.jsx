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
  }
  render() {
    return (
      <FormGroup className={'dropdown-container'}>
        <Label htmlFor="department">Departamentos</Label>
        <Input type="text" id="department" placeholder="Departamentos que utilizam esta área ..." />
        <div className="dropdown-input">
          <ul>
            <li>Brazil</li>
            <li>Argentina</li>
            <li>Chile</li>
            <li>Peru</li>
            <li>Brazil</li>
            <li>Argentina</li>
            <li>Chile</li>
            <li>Peru</li>
            <li>Brazil</li>
            <li>Argentina</li>
            <li>Chile</li>
            <li>Peru</li>
          </ul>
        </div>
      </FormGroup>
    );
  }
}

export default InputWithDropdown;