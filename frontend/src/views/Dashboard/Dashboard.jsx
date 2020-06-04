import React, { Component } from "react";
import { Container, Row, Col, Card, CardBody, Button } from "reactstrap";
import SessionData from "../Authentication/test/SessionData";
// import { tableConfig, selectedData, data, searchableAttributes, filterAttributes, customFilters, dataTree } from './fakeData';
// import svgr from '@svgr/core';
// import CustomTable from "../../components/Tables/CustomTable";
// import Maps from '../../components/Maps/Maps';

class Dashboard extends Component {
  constructor(props) {
    super(props);
  }

  returnData = () => {
    const data = localStorage.getItem('session');
    console.log(data);
  }

  render() {
    return (
      <React.Fragment>

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

        {/* <Container>
          <Row className="justify-content-center">
            <Col md="12">
              <Card className="mx-8">
                <CardBody className="p-8">
                  <Maps />
                </CardBody>
              </Card>
            </Col>
          </Row>
        </Container> */}

      </div>

      <Button
        block
        outline
        color="primary"
        className="px-0"
        onClick={this.returnData}
      >Get Data
      </Button>

      <SessionData/>

      </React.Fragment>
    );
  }
}

export default Dashboard;
