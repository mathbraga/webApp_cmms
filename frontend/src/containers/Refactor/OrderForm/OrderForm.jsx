import React, { Component } from "react";
import { graphql } from 'react-apollo';
import { compose } from 'redux';
import { query, config, mquery, mconfig } from "./graphql";
import { form } from "./form";
import getFieldsFromSchema from '../getFieldsFromSchema';
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

class OrderForm extends Component {
  constructor(props) {
    super(props);
    this.state = {
    }
    this.formRef = React.createRef();
    this.fileInputRef = React.createRef();
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
    // console.clear();
    // console.log(this.fileInputRef.current.files);
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
                  <strong>{form.cardTitle}</strong>
                </CardHeader>
                <CardBody>
                  <Form
                    encType="multipart/form-data"
                    className="form-horizontal"
                    innerRef={this.formRef}
                    onSubmit={this.submitMutation}
                  >
                    {form.inputs.map(input => (
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

                <Row>
                  <Col xs="4">
                    <FormGroup>
                      <CustomInput
                        multiple={true}
                        label="Selecione"
                        type="file"
                        id="files"
                        name="files"
                        innerRef={this.fileInputRef}
                        // onChange={this.handleSelection}
                        // onChange={event => {
                        //   const filename =
                        //     event.target.files.length > 0
                        //       ? event.target.files[0].name
                        //       : "";
                          // document.getElementById(
                          //   `${event.target.id}_filename`
                          // ).value = filename;
                        // }}
                      />
                    </FormGroup>
                  </Col>
                </Row>
                <Row>
                <Button
                    type="submit"
                    size="sm"
                    color="primary"
                    // onClick={this.submitMutation}
                  >Submit
                  </Button>
                </Row>


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
