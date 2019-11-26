import React, { Component } from "react";
import { 
  Col,
  FormGroup,
  Input,
  Label,
} from 'reactstrap';

class InputText extends Component {
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
            type="text"
            autoFocus={input.autoFocus}
            id={input.id}
            name={input.name}
            placeholder={input.placeholder}
            required={input.required}
            onChange={onChange}
          />
        </Col>
      </FormGroup>
    );
  }
}

export default InputText;