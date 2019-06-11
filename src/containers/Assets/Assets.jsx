import React, { Component } from "react";

class Assets extends Component {
  constructor(props){
    super(props);
  }
  render(){

    // const {
    //   filter
    // } = this.props;

    return (
      <React.Fragment>
        <h1>ASSETS PAGE</h1>
        <h1>{"Filter: " + this.props.filter}</h1>
      </React.Fragment>
    )
  }
}

export default Assets;