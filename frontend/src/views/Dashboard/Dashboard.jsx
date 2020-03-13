import React, { Component } from "react";
import { Container, Row, Col, Card, CardBody, } from "reactstrap";
import { tableConfig, selectedData, data, searchableAttributes, filterAttributes, customFilters, dataTree } from './fakeData';
import svgr from '@svgr/core';
import CustomTable from "../../components/Tables/CustomTable";

const svgCode = `
<svg xmlns="http://www.w3.org/2000/svg"
  xmlns:xlink="http://www.w3.org/1999/xlink">
  <rect x="10" y="10" height="100" width="100"
    style="stroke:#ff0000; fill: #0000ff"/>
</svg>
`;

svgr(svgCode, { icon: true }, { componentName: 'MyComponent' }).then(jsCode => {
  console.log(jsCode)
})

class Dashboard extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (
      <div className="flex-row align-items-center animated fadeIn">
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
                  </div>
                </CardBody>
              </Card>
            </Col>
          </Row>
        </Container>

        <Container>
          <Row className="justify-content-center">
            <Col md="12">
              <Card className="mx-8">
                <CardBody className="p-8">
                  hey
                  <svg width="250" height="250">
                    <rect x="25" y="25" rx="25" ry="25" height="200" width="200" fill="steelblue" />
                    <circle r="120" cx="125" cy="125" fill="none" stroke="red" stroke-width="10" />
                    <circle r="70" cx="125" cy="125" fill="none" stroke="red" stroke-width="10" />
                    {/* <line x1="10" y1="125" x2="225" y2="225" stroke="black" stroke-width="25" /> */}
                    <polygon fill="pink" points="50,50 125,125 200,50 200,200 125,125 50,200" />
                  </svg>
                </CardBody>
              </Card>
            </Col>
          </Row>
        </Container>

      </div>
    );
  }
}

export default Dashboard;
