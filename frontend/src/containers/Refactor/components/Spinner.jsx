import React, { Component } from "react";
import { Spinner } from 'reactstrap';

class _Spinner extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (
      <Spinner
        color="secondary"
        style={{ width: '5rem', height: '5rem' }}
      />
    );
  }
}

export default _Spinner;
