import React, { Component } from "react";
import { withRouter } from "react-router-dom";
import { Alert, Card, CardBody, Col, Row, Button, CardHeader, Badge } from "reactstrap";
import "./WorkOrdersTable.css";
import { sortBy } from "lodash";

class WorkOrdersTable extends Component {
  render() {

    let {
      tableConfig,
      items,
      viewEntity
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

          {items.length === 0 ? (

            <Alert
              color="dark"
            >Carregando ordens de serviço...
            </Alert>

          ) : (

            <table className="content-table">
              <thead className="thead-light">
                <tr>
                  {tableConfig.map(column => (
                    <th
                      key={column.name}
                      style={column.style}
                      className="text-center"
                    >{column.name}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {items.map(item => (
                  <tr
                    key={item.id}
                  >
                    {tableConfig.map(column => (
                      <td
                        key={item[column.attr]}
                        className={column.className}
                        style={column.style}
                      >
                        {(column.attr === "id") ? (
                          <Button
                            color="link"
                            style={{color: "black", fontSize: "1.2em"}}
                            name={item[column.attr]}
                            onClick={viewEntity[column.attr]}
                          >{item[column.attr]}
                          </Button>
                        ) : (
                          column.attr === "impact" ? (
                            <React.Fragment>
                              {item[column.attr] ? (
                              <Badge color="warning">
                                Sim
                              </Badge>
                            ) : (
                              <Badge color="light">
                                Não
                              </Badge>
                            )}
                            </React.Fragment>
                        ) : (
                          <React.Fragment>
                            {item[column.attr]}
                          </React.Fragment>
                        ))}
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

export default withRouter(WorkOrdersTable);
