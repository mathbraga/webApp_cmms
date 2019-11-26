import React, { Component } from "react";
import { 
  Col,
  FormGroup,
  Input,
  Label,
} from 'reactstrap';

class InputFiles extends Component {
  constructor(props) {
    super(props);
    this.state = {
    }
  }

  render() {

    const { input, innerRef, onChange } = this.props;

    return (
      <FormGroup row>
        <Col md="3">
          <Label>{input.label}</Label>
        </Col>
        <Col xs="12" md="9">
          <Input
            type="file"
            multiple={true}
            autoFocus={input.autoFocus}
            id={input.id}
            name={input.name}
            placeholder={input.placeholder}
            required={input.required}
            innerRef={innerRef}
            onChange={onChange}
          />
        </Col>
      </FormGroup>
    );
  }
}

export default InputFiles;