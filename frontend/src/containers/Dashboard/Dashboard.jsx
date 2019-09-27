import React, { Component } from "react";
import { Container, Row, Col, Card, CardBody } from "reactstrap";

class Dashboard extends Component {
  constructor(props) {
    super(props);
    this.state = {
    }
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
                      Bem-vindo ao webSINFRA
                      {" "}<i className="fa fa-wrench"></i>
                    </h3>
                    <br />
                    <div className="text-muted text-justify">
                      <p>
                        Esta página dá acesso ao sistema de gestão de manutenção da
                        Secretaria de Infraestrutura do Senado Federal - <b>webSINFRA</b>. Para uma melhor
                        experiência, utilize a versão mais atual do navegador Chrome.
                      </p>
                      <p>
                        Para reportar erros, sanar dúvidas ou sugerir melhorias,
                        entre em contato com o SEPLAG no ramal 2339 ou envie um email para ls_seplag@senado.leg.br.
                      </p>
                      {/* <p>Para contribuir ao código-fonte, acesse o{" "}
                        <a
                          href="https://github.com/Serafabr/cmms-web-app"
                          target="_blank"
                          rel="noopener noreferrer nofollow"
                        >repositório no GitHub
                          {" "}<i className="fa fa-github"></i>
                        </a>
                      </p> */}
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
