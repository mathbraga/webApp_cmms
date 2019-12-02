import React, { Component } from "react";
import { Row, Col, Card, CardHeader, CardBody, Table } from 'reactstrap';

class All extends Component {
  constructor(props) {
    super(props);
  }

  render() {

    const { table, title } = this.props;

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
                      {table.head.map(column => (
                        <th
                          key={column.field}
                        >{column.label}</th>
                      ))}
                      <th>{' '}</th>
                    </tr>
                    
                  </thead>
                  <tbody>
                    {table.body.map((row, i) => (
                      <tr key={i}>
                        {table.head.map(column => (
                          <td key={column.field}>
                            {row[column.field]}
                          </td>
                        ))}
                        <td><a href={row.href}><i className="fa fa-search"></i></a></td>
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
