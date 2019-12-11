import React, { Component } from "react";
import { Row, Col, Spinner } from 'reactstrap';

class _Spinner extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (
      <Row>
        <Col className="text-center">
          <Spinner
            color="secondary"
            style={{
              width: '5rem',
              height: '5rem',
              marginTop: '20%',
            }}
          />
        </Col>
      </Row>
    );
  }
}

export default _Spinner;
