import React, { Component } from "react";
import { Row, Col, Card, CardHeader, CardBody, Table } from 'reactstrap';
import { graphql } from 'react-apollo';
import { qQuery, qConfig } from "./graphql";

class OrderAll extends Component {
  constructor(props) {
    super(props);
    this.state = {
    }
  }

  render() {

    const { error, loading, columns, list, title } = this.props;

    if(error) return <p>{JSON.stringify(error)}</p>;

    if(loading) return <h1>Carregando...</h1>;
    
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

export default graphql(qQuery, qConfig)(OrderAll);
