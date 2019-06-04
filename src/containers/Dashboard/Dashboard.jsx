import React, { Component } from "react";
import { Container, Row, Col, Card, CardBody, Alert } from "reactstrap";

class Dashboard extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (
      <React.Fragment>
        <div className="flex-row align-items-center">
          <Container>
            <Row className="justify-content-center">
              <Col md="8">
                <Card className="mx-4">
                  <CardBody className="p-4">
                    <h3>
                      Bem-vindo à página da SINFRA
                      {" "}<i class="fa fa-wrench"></i>
                    </h3>
                    <br/>
                    <div className="text-muted text-justify">
                      <p>
                        Este portal dá acesso ao{" "}
                        <a
                          href="https://en.wikipedia.org/wiki/Computerized_maintenance_management_system"
                          target="_blank"
                          rel="noopener"
                          >sistema de gestão de manutenção
                        </a>
                        {" "}da SINFRA.
                      </p>
                      <p>
                        Aqui serão disponibilizadas ferramentas computacionais para os colaboradores da Secretaria
                        e divulgadas informações úteis para outros setores do Senado Federal.
                      </p>
                      <p>
                        A versão atual inclui a funcionalidade do "monitor de consumo",
                        que permite pesquisar dados das faturas de água (CAESB) e energia elétrica (CEB).
                        Novas funcionalidades serão adicionadas em breve.
                      </p>
                      <p>Para contribuições:{" "}
                        <a
                          href="https://github.com/Serafabr/cmms-web-app"
                          target="_blank"
                          rel="noopener"
                        >repositório no GitHub{" "}
                          <i className="fa fa-github"></i>
                        </a>
                      </p>
                      <p>
                        Dúvidas e sugestões: SEPLAG (ramal 2339)
                      </p>
                    </div>
                  </CardBody>
                </Card>
              </Col>
            </Row>
          </Container>
        </div>
      </React.Fragment>
    );
  }
}

export default Dashboard;
