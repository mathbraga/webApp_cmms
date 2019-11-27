import React, { Component } from "react";
import { graphql } from 'react-apollo';
import { compose } from 'redux';
import { qQuery, qConfig, mQuery, mConfig, getVariables } from "./graphql";
import _Form from '../../components/Form';
import getFiles from '../../utils/getFiles';

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
    return this.props.mutate({
      variables: {
        ...getVariables(this.state),
        ...getFiles(this.innerRef.current.files)
      }
    });
  }

  render() {

    const { error, loading, config } = this.props;

    if(error) return <p>{JSON.stringify(error)}</p>;

    if(loading) return <h1>Carregando...</h1>;
    
    return (
      <_Form
        config={config}
        innerRef={this.innerRef}
        onChange={this.handleChange}
        onSubmit={this.handleSubmit}
        loading={loading}
      />
    );
  }
}

export default compose(
  graphql(qQuery, qConfig),
  graphql(mQuery, mConfig)
)(OrderForm);
