import React, { Component } from "react";
import { Container, Row, Col, Card, CardBody } from "reactstrap";

class Dashboard extends Component {
  constructor(props){
    super(props);
    this.state = {
    }
  }


  componentDidMount(){
    console.clear();
    fetch('http://localhost:3001/search?med=101&aamm1=1701&aamm2=1701', {
      method: "GET"
    })
    .then(response=>response.json())
    .then(data=>console.log(data))
    .catch(()=>console.log('erro ao realizar fetch'));
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
                      {" "}<i className="fa fa-wrench"></i>
                    </h3>
                    <br/>
                    <div className="text-muted text-justify">
                      <p>
                        Este portal dá acesso ao sistema de gestão de manutenção da
                        Secretaria de Infraestrutura do Senado Federal. Para uma melhor
                        experiência, utilize a versão mais atual do navegador Chrome.
                        {/* {" "}
                        <a
                          href="https://en.wikipedia.org/wiki/Computerized_maintenance_management_system"
                          target="_blank"
                          rel="noopener noreferrer nofollow"
                          >sistema de gestão de manutenção
                        </a>
                        {" "}da SINFRA. */}
                      </p>
                      <p>
                        Aqui serão disponibilizadas ferramentas computacionais para os
                        colaboradores desse setor e divulgadas informações úteis.
                      </p>
                      <p>
                        Neste momento está disponível o "monitor de consumo",
                        que permite pesquisar dados das faturas de energia elétrica.
                        Novas funcionalidades estão em desenvolvimento e serão adicionadas em breve.
                      </p>
                      <p>
                        Para reportar erros, sanar dúvidas ou dar sugestões,
                        entre em contato com o SEPLAG no ramal 2339 ou envie um email para ls_seplag@senado.leg.br.
                      </p>
                      <p>Para contribuir ao código-fonte, acesse o{" "}
                        <a
                          href="https://github.com/Serafabr/cmms-web-app"
                          target="_blank"
                          rel="noopener noreferrer nofollow"
                        >repositório no GitHub.
                          {/*{" "}<i className="fa fa-github"></i> */}
                        </a>
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
