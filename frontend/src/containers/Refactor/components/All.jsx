import React, { Component } from "react";
import { Row, Col, Card, CardHeader, CardBody, Table } from 'reactstrap';

class All extends Component {
  constructor(props) {
    super(props);
  }

  render() {

    const { columns, list, title } = this.props;

    return (
      <div className="animated fadeIn">
        <Row>
          <Col xs="9">
            <Card>
              <CardHeader>
                <strong>{title}</strong>
              </CardHeader>
              <CardBody>
                <Table hover>
                  <thead>
                    <tr>
                      {columns.map(column => (
                        <th>{column.label}</th>
                      ))}
                    </tr>
                  </thead>
                  <tbody>
                    {list.map(item => (
                      <tr>
                        {columns.map(column => (
                          <td>
                            {item[column.field]}
                          </td>
                        ))}
                      </tr>
                    ))}
                  </tbody>
                </Table>
              </CardBody>
            </Card>
          </Col>
        </Row>
      </div>
    );
  }
}

export default All;
