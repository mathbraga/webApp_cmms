import React, { Component } from "react";
import { graphql } from 'react-apollo';
import { compose } from 'redux';
import { qQuery, qConfig, mQuery, mConfig } from "./graphql";
import config from "./config";
import { 
  Button,
  Card,
  CardBody,
  CardHeader,
  Col,
  Form,
  FormGroup,
  Row,
} from 'reactstrap';
import getFiles from '../../utils/getFiles';
import getFilesMetadata from '../../utils/getFilesMetadata';
import _Input from '../../components/Inputs/Input';

class _Form extends Component {
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

    const { error, loading } = this.props;

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
                  <strong>{config.title}</strong>
                </CardHeader>
                <CardBody>
                  <Form>
                    {config.inputs.map(input => (
                      <_Input
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
  graphql(qQuery, qConfig),
  graphql(mQuery, mConfig)
)(_Form);
