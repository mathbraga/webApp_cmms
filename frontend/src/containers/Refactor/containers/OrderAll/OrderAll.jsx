import React, { Component } from "react";
import All from '../../components/All';
import _Spinner from '../../components/Spinner';
import { graphql } from 'react-apollo';
import { qQuery, qConfig } from "./graphql";

class OrderAll extends Component {
  constructor(props) {
    super(props);
  }

  render() {

    const { error, loading, table, title } = this.props;

    if(error) return <p>{JSON.stringify(error)}</p>;

    if(loading) return <_Spinner />;
    
    return (
      <All
        title={title}
        table={table}
      />
    );
  }
}

export default graphql(qQuery, qConfig)(OrderAll);
