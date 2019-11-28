import React, { Component } from "react";
import One from '../../components/One';
import _Spinner from '../../components/Spinner';
import { graphql } from 'react-apollo';
import { qQuery, qConfig } from "./graphql";

class OrderOne extends Component {
  constructor(props) {
    super(props);
  }

  render() {

    const { error, loading, one, files } = this.props;

    if(error) return <p>{JSON.stringify(error)}</p>;

    if(loading) return <_Spinner />;
    
    return (
      <One
        one={one}
      />
    );
  }
}

export default graphql(qQuery, qConfig)(OrderOne);
