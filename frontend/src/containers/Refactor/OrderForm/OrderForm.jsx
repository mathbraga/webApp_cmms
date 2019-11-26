import React, { Component } from "react";
import { graphql } from 'react-apollo';
import { compose } from 'redux';
import { query, config, mquery, mconfig } from "./graphql";
import { form } from "./form";
import { 
  Badge,
  Button,
  Card,
  CardBody,
  CardFooter,
  CardHeader,
  Col,
  CustomInput,
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
import getFiles from './getFiles';
import getFilesMetadata from './getFilesMetadata';
import SwitchInputs from '../Inputs/SwitchInputs';

class OrderForm extends Component {
  constructor(props) {
    super(props);
    this.state = {
    }
    this.fileInputRef = React.createRef();
    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  handleChange(event) {
    if (event.target.value.length === 0)
      return this.setState({ [event.target.name]: null });
    this.setState({ [event.target.name]: event.target.value });
  }

  handleSubmit(event) {
    event.preventDefault();
    return this.props.mutate({
      variables: {
        contractId: Number(this.state.contractId),
        testText: this.state.text,
        filesMetadata: getFilesMetadata(this.fileInputRef.current.files),
        files: getFiles(this.fileInputRef.current.files)
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
                  <strong>{"Título"}</strong>
                </CardHeader>
                <CardBody>
                  <Form>
                    {form.inputs.map(input => (
                      <SwitchInputs
                        key={input.name}
                        input={input}
                        onChange={this.handleChange}
                        innerRef={input.type === 'file' ? this.fileInputRef : null}
                      />
                    ))}
                    <FormGroup row>
                      <Col>
                        <Button
                            type="button"
                            color="primary"
                            onClick={this.handleSubmit}
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
}

export default compose(
  graphql(query, config),
  graphql(mquery, mconfig)
)(OrderForm);




/*
                      <FormGroup
                        row
                        key={input.id}
                      >
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
                              <option
                                key={'0'}
                                label={'Selecione o contrato'}
                                value={null}
                              ></option>
                              {contracts.map(contract => (
                                <option
                                  key={contract.contractId}
                                  label={contract.contractSf}
                                  value={contract.contractId}
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

                    <FormGroup row>
                      <Col md="3">
                        <Label>Arquivos</Label>
                      </Col>
                      <Col xs="12" md="9">
                        <Input
                          multiple={true}
                          label="Selecione"
                          type="file"
                          id="files"
                          name="files"
                          innerRef={this.fileInputRef}
                        />
                      </Col>
                    </FormGroup>

                    <FormGroup row>
                      <Col>
                        <Button
                            type="button"
                            size="sm"
                            color="primary"
                            // onClick={this.submitMutation}
                          >Enviar
                        </Button>
                      </Col>
                    </FormGroup>
*/

