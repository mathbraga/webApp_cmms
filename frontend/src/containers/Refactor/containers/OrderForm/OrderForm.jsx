import React, { Component } from "react";
import _Form from '../../components/Form';
import _Spinner from '../../components/Spinner';
import { graphql } from 'react-apollo';
import { compose } from 'redux';
import { qQuery, qConfig, mQuery, mConfig, getVariables } from "./graphql";
import getFiles from '../../utils/getFiles';
import getMultipleSelect from '../../utils/getMultipleSelect';

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
    event.persist();
    const name = event.target.name;
    const value = event.target.value;
    const options = event.target.options;
    if (value.length === 0)
      return this.setState({ [name]: null });
    if (name === 'assets'){
      this.setState({ assets: getMultipleSelect(options) });
    } else {
      this.setState({ [name]: value });
    }
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

    const { error, loading, form } = this.props;

    if(error) return <p>{JSON.stringify(error)}</p>;

    if(loading) return <_Spinner />;
    
    return (
      <_Form
        form={form}
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
