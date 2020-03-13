import React, { Component } from "react";
import { Container, Row, Col, Card, CardBody, } from "reactstrap";
import { tableConfig, selectedData, data, searchableAttributes, filterAttributes, customFilters, dataTree } from './fakeData';

import CustomTable from "../../components/NewTables/CustomTable";

class Dashboard extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (
      // <div className="flex-row align-items-center animated fadeIn">
      //   <Container>
      //     <Row className="justify-content-center">
      //       <Col md="8">
      //         <Card className="mx-4">
      //           <CardBody className="p-4">
      //             <h3>
      //               Bem-vindo ao webSINFRA
      //               {" "}<i className="fa fa-wrench"></i>
      //             </h3>
      //             <br />
      //             <div className="text-muted text-justify">
      //               <p>
      //                 Esta página dá acesso ao sistema de gestão de manutenção da
      //                 Secretaria de Infraestrutura do Senado Federal - <b>webSINFRA</b>. Para uma melhor
      //                 experiência, utilize a versão mais atual do navegador Chrome.
      //               </p>
      //               <p>
      //                 Para reportar erros, sanar dúvidas ou sugerir melhorias,
      //                 entre em contato com o SEPLAG no ramal 2339 ou envie um email para ls_seplag@senado.leg.br.
      //               </p>
      //             </div>
      //           </CardBody>
      //         </Card>
      //       </Col>
      //     </Row>
      //   </Container>

        /* <Container>
          <Row className="justify-content-center">
            <Col md="12">
              <Card className="mx-8">
                <CardBody className="p-8">
                  <CustomTable
                    type={"full"}
                    tableConfig={tableConfig}
                    selectedData={selectedData}
                    data={data}
                    searchableAttributes={searchableAttributes}
                    filterAttributes={filterAttributes}
                    customFilters={customFilters}
                  />
                </CardBody>
              </Card>
            </Col>
          </Row>
        </Container> */

      //</div>

      <div>
        <Container>
          <Row className="justify-content-center">
            <Col md="8">
              <Card className="mx-4">
                <CardBody className="p-4">
                  <div className="history__main">
                    <div className="history__date">Quarta-feira 11/03/2020</div>
                    <div className="history__occurence">Modificação no ativo.</div>
                    <div className="history__time">15:22</div>
                  </div>
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
