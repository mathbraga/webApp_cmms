import React, { Component } from "react";
import { Row, Col, Card, CardHeader, CardBody, Table } from 'reactstrap';

class One extends Component {
  constructor(props) {
    super(props);
  }

  render() {

    const { one } = this.props;

    return (
      <div className="animated fadeIn">
        <Row>
          <Col xs="12">
            <Card>
              <CardHeader>
                <strong>{one.title}</strong>
              </CardHeader>
              <CardBody>
              </CardBody>
            </Card>
          </Col>
        </Row>
      </div>
    );
  }
}

export default One;
