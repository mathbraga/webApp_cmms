import React, { Component } from "react";
import { 
  Col,
  FormGroup,
  Input,
  Label,
} from 'reactstrap';

class InputDate extends Component {
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
            type="date"
            autoFocus={input.autoFocus}
            id={input.id}
            name={input.name}
            required={input.required}
            onChange={onChange}
          />
        </Col>
      </FormGroup>
    );
  }
}

export default InputDate;