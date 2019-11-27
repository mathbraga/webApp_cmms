import React, { Component } from "react";
import { graphql } from 'react-apollo';
import { qQuery, qConfig } from "./graphql";

class OrderAll extends Component {
  constructor(props) {
    super(props);
    this.state = {
    }
  }

  render() {

    const { error, loading, list } = this.props;

    if(error) return <p>{JSON.stringify(error)}</p>;

    if(loading) return <h1>Carregando...</h1>;
    
    return (
      <p>{JSON.stringify(list)}</p>
    );
  }
}

export default graphql(qQuery, qConfig)(OrderAll);
