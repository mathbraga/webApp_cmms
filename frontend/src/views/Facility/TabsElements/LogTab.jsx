import React, { Component } from 'react';
import { Container, Row, Col, Card, CardBody, } from "reactstrap";
import "./history.css";

class LogTab extends Component {
  state = {}
  render() {
    return (
    <div>
      {/* <Container> */}
        {/* <Row className="justify-content-center"> */}
          {/* <Col md="8">
            <Card className="mx-4">
              <CardBody className="p-4"> */}
                <div className="history__main">
                  <div className="history__date">11/03/2020 <span className="text-muted">Quarta-feira</span></div>
                  <div className="history__items">
                    <div className="history__icon"><span className="history__initials">SF</span></div>
                    <div className="history__occurence">
                      <div className="history__creator">Nome</div>
                      <div className="history__description">atualizou o ativo <span>CASF</span></div>
                      <ul>
                        <li>Nome do ativo alterado para "Novo nome"</li>
                        <li>Valor do ativo alterado para "Novo valor"</li>
                      </ul>
                      <div className="text-muted">Atualizado às 15:22</div>
                    </div>
                  </div>
                </div>
              {/* </CardBody>
            </Card>
          </Col> */}
        {/* </Row> */}
      {/* </Container> */}
    </div>
    );
  }
}

export default LogTab;