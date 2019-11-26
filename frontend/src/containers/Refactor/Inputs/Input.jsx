import React, { Component } from "react";
import { 
  Col,
  FormGroup,
  Input,
  Label,
} from 'reactstrap';

class _Input extends Component {
  constructor(props) {
    super(props);
    this.state = {
    }
  }

  render() {

    const { input, onChange, innerRef } = this.props;

    return (
      <FormGroup row>
        <Col md="3">
          <Label>{input.label} {input.required ? ' *' : ''}
          </Label>
        </Col>
        <Col xs="12" md="9">
          <Input
            type={input.type}
            autoFocus={input.autoFocus}
            id={input.id}
            name={input.name}
            placeholder={input.placeholder}
            required={input.required}
            onChange={onChange}
            innerRef={innerRef}
          >
            {input.type === 'select' ? (
              <React.Fragment>
                <option value={null}>{input.placeholder}</option>
                {input.options.map(option => 
                  <option
                    key={option.value}
                    value={option.value}
                  >{option.text}</option>
                )}
              </React.Fragment>
            ) : (
              null
            )}
          </Input>
        </Col>
      </FormGroup>
    );
  }
}

export default _Input;