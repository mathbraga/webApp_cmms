import React, { Component } from "react";
import { Card, CardBody, Col, Row, Button, CardHeader } from "reactstrap";

class WorkRequestsTable extends Component {
  render() {
    return (
      <React.Fragment>
        <Card>
        <CardHeader>
          <Row>
            <Col md="9" xs="6">
              <div className="widget-title dash-title text-truncate">
                <h4></h4>
                  <div className="dash-subtitle text-truncate">
                    
                  </div>
              </div>
              <div className="widget-container-center">
                  <div className="dash-title-info text-truncate">
                   
                  </div>
               
                
                  <div className="dash-title-info text-truncate">

                  </div>
               
              </div>
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

        </CardBody>
      </Card>



      </React.Fragment>
    );
  }
}

export default WorkRequestsTable;
