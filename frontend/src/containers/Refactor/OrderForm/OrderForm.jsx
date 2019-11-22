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
    console.clear();
    // console.log(event)
    // const fd = new FormData(event.target);
    // const filename = fd.get('files');
    // console.log(filename);
    console.log(this.fileInputRef.current.files)
    if(this.fileInputRef.current.files.length > 0){
      return this.props.mutate({
        variables: {
          contractId: 1,
          testText: "texto",
          fileMetadata: this.fileInputRef.current.files,
        }
      });
    }
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
                  <Form
                    encType="multipart/form-data"
                    className="form-horizontal"
                    innerRef={this.formRef}
                    onSubmit={this.submitMutation}
                  >
                    {formConfig.inputs.map(input => (
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

                <Row>
                  <Col xs="4">
                    <FormGroup>
                      <CustomInput
                        // multiple={true}
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
