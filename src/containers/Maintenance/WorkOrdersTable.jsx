import React, { Component } from "react";
import { Card, CardBody, Col, Row, Button, CardHeader } from "reactstrap";
import "./WorkOrdersTable.css";

class WorkRequestsTable extends Component {
  render() {

    let {
      tableConfig,
      items
    } = this.props;

    return (
      <React.Fragment>
        <Card>
        <CardHeader>
          <Row>
            <Col md="9" xs="6">
              <div className="calc-title">Ordens de serviço</div>
            </Col>

            <Col md="3" xs="6" className="container-left">
              <Button
                className="text-truncate"
                block
                outline
                color="primary"
                onClick={() => {this.props.history.push("/manutencao/os/nova")}}
                style={{ width: "auto", padding: "8px 25px" }}
              >
                Nova OS
              </Button>
            </Col>
          </Row>
        </CardHeader>
        <CardBody>
        <table className="content-table">
        <thead className="thead-light">
          <tr>
            {tableConfig.map(column => (
              <th style={column.style} className={column.className}>{column.name}</th>
            ))}
          </tr>
        </thead>
        <tbody>
          {items.map(item => (
            <tr>
              <td className="text-center">sdfsdfs</td>
              <td className="text-center">sdfsdfs</td>
              <td className="text-center">sdfsdfs</td>
              <td className="text-center">sdfsdfs</td>
            </tr>
          ))}
        </tbody>
      </table>



        </CardBody>
      </Card>



      </React.Fragment>
    );
  }
}

export default WorkRequestsTable;
