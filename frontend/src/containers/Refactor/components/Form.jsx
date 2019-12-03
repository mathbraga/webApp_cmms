import React, { Component } from "react";
import { 
  Button,
  Card,
  CardBody,
  CardHeader,
  Col,
  Form,
  FormGroup,
  Input,
  Label,
  Row,
} from 'reactstrap';

class _Form extends Component {
  constructor(props) {
    super(props);
    this.state = {
    }
  }

  render() {

    const { form, innerRef, onChange, onSubmit, loading } = this.props;

    return (
      
            
              
                <Form>
                  {form.inputs.map(input => (
                    <FormGroup row key={input.name}>
                      <Col md="3">
                        <Label>{input.label} {input.required ? ' *' : ''}
                        </Label>
                      </Col>
                    <Col xs="12" md="9">
                      <Input
                        type={input.type}
                        autoFocus={input.autoFocus}
                        disabled={loading}
                        id={input.id}
                        name={input.name}
                        placeholder={input.placeholder}
                        required={input.required}
                        onBlur={onChange}
                        onChange={input.onChange ? onChange : () =>{}}
                        innerRef={input.type === 'file' ? innerRef : null}
                        multiple={input.multiple}
                        style={input.multiple && input.name !== 'files' ? {height: '10rem'} : {}}
                      >
                        {input.type === 'select' ? (
                          <React.Fragment>
                            {!input.multiple ? (
                              <option value={null}>{input.placeholder}</option>
                            ) : (
                              null
                            )}
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
                  ))}
                  {/* <FormGroup row>
                    <Col>
                      <Button
                        block
                        disabled={loading}
                        type="button"
                        color="primary"
                        onClick={onSubmit}
                      >{form.button}
                      </Button>
                    </Col>
                  </FormGroup> */}
                </Form>
    );
  }
}

export default _Form;
