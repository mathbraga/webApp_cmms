import React, { Component } from "react";
import { graphql } from 'react-apollo';
import { gqlQuery } from "./config";

class Test extends Component {
  constructor(props) {
    super(props);
    this.state = {
    }
  }

  render() {

    const data = this.props.data;

    if(data.error) return <h1>{data.error}</h1>;
    if(data.loading) return <h1>Carregando...</h1>
    else{

      console.log(data);

      return (
        <React.Fragment>
          <h1>Query ok</h1>
          <p>{JSON.stringify(data)}</p>
        </React.Fragment>
      );
    }
  }
}

export default graphql(
  gqlQuery,
  {
    options: {
      variables: {var1: 'var1'},
      fetchPolicy: 'no-cache',
      errorPolicy: 'ignore',
      pollInterval: 0,
      notifyOnNetworkStatusChange: false,
    },
    // props: ,
    skip: false,
    // name: ,
    // withRef: ,
    // alias: ,
  }
)(Test);
