import React, { Component } from "react";
import { Alert, Card, CardBody, Col, Row, Button, CardHeader } from "reactstrap";
import "./WorkOrdersTable.css";

class WorkRequestsTable extends Component {
  render() {

    let {
      tableConfig,
      items
    } = this.props;

    return (
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

          {this.props.items.length === 0 ? (

            <Alert
              color="dark"
            >Carregando ordens de serviço...
            </Alert>

          ) : (

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
                    {tableConfig.map(column => (
                      <td className="text-center">
                        {(column.attr === "local") || (column.attr === "asset") ? (
                          <Button
                            color="link"
                            name={item[column.attr]}
                            onClick={column.attr === "local" ? this.props.viewLocal : this.props.viewAsset}
                          >{item[column.attr]}
                          </Button>
                        ) : (
                          <React.Fragment>
                            {item[column.attr]}
                          </React.Fragment>
                        )}
                      </td>
                    ))}
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </CardBody>
      </Card>
    );
  }
}

export default WorkRequestsTable;
