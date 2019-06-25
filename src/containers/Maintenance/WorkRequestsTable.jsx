import React, { Component } from "react";
import { Card, CardBody, Col, Row, Button, CardHeader } from "reactstrap";

class WorkRequestsTable extends Component {
  render() {

    let {
      items
    } = this.props;

    return (
      <React.Fragment>
        <Card>
        <CardHeader>
          <Row>
            <Col md="9" xs="6">
              <div className="calc-title">Minhas solicitações</div>
            </Col>

            <Col md="3" xs="6" className="container-left">
              <Button
                className="text-truncate"
                block
                outline
                color="primary"
                onClick={() => {this.props.history.push("/manutencao/solicitacoes/nova")}}
                style={{ width: "auto", padding: "8px 25px" }}
              >
                Nova solicitação
              </Button>
            </Col>
          </Row>
        </CardHeader>
        <CardBody>
          <table>
            <tr>
              <th>id</th>
              <th>selected service</th>
              <th>local</th>
              <th>creation date</th>
              <th>last update</th>
            </tr>

            {items.map(item => (
              <tr>
                <td>{item.id}</td>
                <td>{item.selectedService}</td>
                <td>{item.local}</td>
                <td>{item.creationDate}</td>
                <td>{item.lastUpdate}</td>
              </tr>
            ))}

          </table>
        </CardBody>
      </Card>



      </React.Fragment>
    );
  }
}

export default WorkRequestsTable;
