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
                        <th
                          key={column.field}
                        >{column.label}</th>
                      ))}
                      <th>{' '}</th>
                    </tr>
                    
                  </thead>
                  <tbody>
                    {list.map((item, i) => (
                      <tr key={i}>
                        {columns.map(column => (
                          <td key={column.field}>
                            {item[column.field]}
                          </td>
                        ))}
                        <td><a href={item.href}><i className="fa fa-search"></i></a></td>
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
