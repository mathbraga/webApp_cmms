import React, { Component } from "react";
import { Button, } from 'reactstrap';
import { withRouter } from 'react-router-dom';

class BackButton extends Component {
  constructor(props) {
    super(props);
    this.handleCancel = this.handleCancel.bind(this);
  }

  handleCancel(){
    this.props.history.goBack();
  }

  render() {

    return (
      <Button onClick={this.handleCancel}>X</Button>
    );
  }
}

export default withRouter(BackButton);
