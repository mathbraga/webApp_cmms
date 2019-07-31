import React, { Component } from "react";
import { Card, CardBody, Col, Row, Button, CardHeader } from "reactstrap";

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
          {/* <table>

            <tr>
              {tableConfig.map(row => (
                <th>{row.name}</th>
              ))}
            </tr>

            {items.map(item => (
              <tr>
                {tableConfig.map(row => (
                  <td>{item[row.key]}</td>
                ))}
              </tr>
            ))}

          </table> */}
        </CardBody>
      </Card>



      </React.Fragment>
    );
  }
}

export default WorkRequestsTable;
