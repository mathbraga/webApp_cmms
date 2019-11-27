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
      <div className="animated fadeIn">
        <Row>
          <Col xs="12" md="6">
            <Card>
              <CardHeader>
                <strong>{form.title}</strong>
              </CardHeader>
              <CardBody>
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
                        onChange={onChange}
                        innerRef={input.type === 'file' ? innerRef : null}
                        multiple={input.multiple}
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
                  ))}
                  <FormGroup row>
                    <Col>
                      <Button
                        disabled={loading}
                        type="button"
                        color="primary"
                        onClick={onSubmit}
                      >Enviar
                      </Button>
                    </Col>
                  </FormGroup>
                </Form>
              </CardBody>
            </Card>
          </Col>
        </Row>
      </div>
    );
  }
}

export default _Form;
