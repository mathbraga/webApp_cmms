import React, { Component } from "react";
import { graphql } from 'react-apollo';
import { query, config } from "./graphql";

class All extends Component {
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

      // console.log(data);

      return (
        <React.Fragment>
          <h1>Query ok</h1>
          <p>{JSON.stringify(data)}</p>
        </React.Fragment>
      );
    }
  }
}

export default graphql(query, config)(All);
