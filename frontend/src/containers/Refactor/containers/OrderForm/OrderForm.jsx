import React, { Component } from "react";
import { graphql } from 'react-apollo';
import { compose } from 'redux';
import { qQuery, qConfig, mQuery, mConfig } from "./graphql";
import _Form from '../../components/Form';
import getFiles from '../../utils/getFiles';
import getFilesMetadata from '../../utils/getFilesMetadata';

class OrderForm extends Component {
  constructor(props) {
    super(props);
    this.state = {
    }
    this.innerRef = React.createRef();
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
    console.log(this.innerRef.current.files)
    return this.props.mutate({
      variables: {
        contractId: Number(this.state.contractId),
        testText: this.state.text,
        filesMetadata: getFilesMetadata(this.innerRef.current.files),
        files: getFiles(this.innerRef.current.files)
      }
    });
  }

  render() {

    const { config } = this.props;

    return (
      <_Form
        config={config}
        innerRef={this.innerRef}
        onChange={this.handleChange}
        onSubmit={this.handleSubmit}
      />
    );
  }
}

export default compose(
  graphql(qQuery, qConfig),
  graphql(mQuery, mConfig)
)(OrderForm);
