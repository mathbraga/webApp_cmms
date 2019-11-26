import React, { Component } from "react";
import { 
  Col,
  FormGroup,
  Input,
  Label,
} from 'reactstrap';

class InputSelect extends Component {
  constructor(props) {
    super(props);
    this.state = {
    }
  }

  render() {

    const { input, onChange } = this.props;

    return (
      <FormGroup row>
        <Col md="3">
          <Label>{input.label}</Label>
        </Col>
        <Col xs="12" md="9">
          <Input
            type="select"
            autoFocus={input.autoFocus}
            id={input.id}
            name={input.name}
            required={input.required}
            onChange={onChange}
          >
            <option value={null}>{input.placeholder}</option>
            {input.options.map(option => 
              <option
                key={option.value}
                value={option.value}
              >{option.text}</option>
            )}
          </Input>
        </Col>
      </FormGroup>
    );
  }
}

export default InputSelect;