import React, { Component } from "react";
import { graphql } from 'react-apollo';
import { compose } from 'redux';
import { query, config, formConfig, mquery, mconfig } from "./inputs";
import { 
  Badge,
  Button,
  Card,
  CardBody,
  CardFooter,
  CardHeader,
  Col,
  Collapse,
  DropdownItem,
  DropdownMenu,
  DropdownToggle,
  Fade,
  Form,
  FormGroup,
  FormText,
  FormFeedback,
  Input,
  InputGroup,
  InputGroupAddon,
  InputGroupButtonDropdown,
  InputGroupText,
  Label,
  Row,
} from 'reactstrap';

class OrderForm extends Component {
  constructor(props) {
    super(props);
    this.state = {
    }
    this.handleInputChange = this.handleInputChange.bind(this);
    this.submitMutation = this.submitMutation.bind(this);
  }

  handleInputChange(event) {
    if (event.target.value.length === 0)
      return this.setState({ [event.target.name]: null });
    this.setState({ [event.target.name]: event.target.value });
  }

  submitMutation(event) {
    event.preventDefault();
    return this.props.mutate({
      variables: {
        contractId: Number(this.state.contract),
        testText: this.state.text
      }
    });
  }

  render() {

    const { contracts, error, loading } = this.props;

    if(error) {
      return <p>{JSON.stringify(error)}</p>;
    } else if (loading) {
      return <h1>Carregando...</h1>;
    } else {
      return (
        <div className="animated fadeIn">
          <Row>
            <Col xs="12" md="6">
              <Card>
                <CardHeader>
                  <strong>{formConfig.cardTitle}</strong>
                </CardHeader>
                <CardBody>
                  <Form encType="multipart/form-data" className="form-horizontal">
                    {formConfig.inputs.map(input => (
                      <FormGroup row key={input.id}>
                        <Col md="3">
                          <Label htmlFor={input.id}>{input.label}</Label>
                        </Col>
                        <Col xs="12" md="9">
                          {input.type === 'select' ? (
                            <Input
                              type={input.type}
                              id={input.id}
                              name={input.name}
                              placeholder={input.placeholder}
                              required={input.required}
                              onChange={this.handleInputChange}
                            >
                              {input.selectOptions.map(option => (
                                <option
                                  key={option.label}
                                  label={option.label}
                                  name={option.name}
                                  id={option.id}
                                  value={option.value}
                                ></option>
                              ))}
                            </Input>
                          ) : (
                            <Input
                                type={input.type}
                                id={input.id}
                                name={input.name}
                                placeholder={input.placeholder}
                                required={input.required}
                                onChange={this.handleInputChange}
                            />
                          )}
                        </Col>
                      </FormGroup>
                    ))}
                  </Form>
                </CardBody>
                <CardFooter>
                  <Button
                    type="submit"
                    size="sm"
                    color="primary"
                    onClick={this.submitMutation}
                  >Submit
                  </Button>
                  <Button type="reset" size="sm" color="danger">Reset</Button>
                </CardFooter>
              </Card>
            </Col>
          </Row>
        </div>
      );
    }
  }
}

export default compose(
  graphql(query, config),
  graphql(mquery, mconfig)
)(OrderForm);
