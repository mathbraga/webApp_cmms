import React, { Component } from 'react';
import {
  Label,
  Input,
  FormGroup,
  Form,
  Col,
  NavItem,
  Nav,
  NavLink,
  TabContent,
  TabPane,
} from 'reactstrap';

import AssetCard from '../../components/Cards/AssetCard'
import InputWithDropdown from '../../components/Forms/InputWithDropdown';
import SingleInputWithDropDown from '../../components/Forms/SingleInputWithDropdown';

import { withRouter } from "react-router-dom";
import { Query } from 'react-apollo';
import gql from 'graphql-tag';

const ORDER_STATUS = [
  { id: 'can', name: 'Cancelado' },
  { id: 'neg', name: 'Negado' },
  { id: 'sus', name: 'Suspenso' },
  { id: 'fil', name: 'Fila de espera' },
  { id: 'exe', name: 'Em execução' },
  { id: 'conc', name: 'Concluído' },
];

const ORDER_PRIORITY = [
  { id: 'bai', name: 'Baixa' },
  { id: 'nor', name: 'Normal' },
  { id: 'alt', name: 'Alta' },
  { id: 'urg', name: 'Urgente' },
];

const ORDER_CATEGORY = [
  { id: 'hid', name: 'Manutenção Hidráulica' },
  { id: 'ele', name: 'Manutenção Elétrica' },
  { id: 'mec', name: 'Manutenção Mecânica' },
  { id: 'civ', name: 'Manutenção Civil' },
  { id: 'ins', name: 'Instalações Elétricas' },
];

const assets = [
  { id: 'ACAT-001-001', name: 'Ar condicionado - Midea' },
  { id: 'AFDE-001-001', name: 'Casa de máquinas' },
  { id: 'QDEL-001-001', name: 'Quadro de energia elétrica - Sinfra' },
  { id: 'QDEL-001-002', name: 'Quadro de energia elétrica - Coemant' },
  { id: 'QDEL-001-003', name: 'Quadro de energia elétrica - Seplag' },
  { id: 'GMG1-001-001', name: 'Grupo motor gerador - Painel' },
  { id: 'GMG1-001-002', name: 'Grupo motor gerador - Motor' },
  { id: 'GMG1-002-003', name: 'Grupo motor gerador - Gerador' },
  { id: 'ANX2-001-001', name: 'Anexo 2 - Rui Barbosa' },
  { id: 'ANX2-002-001', name: 'Anexo 2 - Petrônio Portela' },
  { id: 'ANX2-003-001', name: 'Anexo 2 - Auditório' },
  { id: 'ANX1-001-001', name: 'Anexo 1 - Pavimento 01' },
  { id: 'ANX1-002-001', name: 'Anexo 1 - Pavimento 02' },
  { id: 'ANX1-003-001', name: 'Anexo 1 - Pavimento 03' },
  { id: 'ANX1-004-001', name: 'Anexo 1 - Pavimento 04' },
];

// const facilities = [
//   { id: 'BL14-001-001', name: 'Bloco 14 - Pavimento 01' },
//   { id: 'BL14-002-001', name: 'Bloco 14 - Pavimento 02' },
//   { id: 'ANX2-001-001', name: 'Anexo 2 - Rui Barbosa' },
//   { id: 'ANX2-002-001', name: 'Anexo 2 - Petrônio Portela' },
//   { id: 'ANX2-003-001', name: 'Anexo 2 - Auditório' },
//   { id: 'ANX1-001-001', name: 'Anexo 1 - Pavimento 01' },
//   { id: 'ANX1-002-001', name: 'Anexo 1 - Pavimento 02' },
//   { id: 'ANX1-003-001', name: 'Anexo 1 - Pavimento 03' },
//   { id: 'ANX1-004-001', name: 'Anexo 1 - Pavimento 04' },
// ];

const contract = [
  { id: 'CT001-2019', name: 'Contrato para manutenção elétrica - RCS Tecnologia' },
  { id: 'CT002-2019', name: 'Contrato para manutenção hidráulica - RCS Tecnologia' },
  { id: 'CT003-2019', name: 'Contrato para manutenção civil - AWS Soluções' },
  { id: 'CT004-2019', name: 'Contrato para pintura - RCS Tecnologia' },
  { id: 'CT005-2019', name: 'Contrato para impermeabilização - PREFAC' },
  { id: 'CT006-2019', name: 'Contrato para manutenção de elevadores - RCS Tecnologia' },
  { id: 'CT007-2019', name: 'Contrato para manutenção dos geradores - RCS Tecnologia' },
  { id: 'CT008-2019', name: 'Contrato para abastecimento dos Geradores - RCS Tecnologia' },
];

// const orders = [
//   { id: 'RQ-001', name: 'Troca de torneiras no Gabinete do Senador José Serra.' },
//   { id: 'RQ-002', name: 'Conserto de tomadas na cozinha.' },
//   { id: 'RQ-003', name: 'Pintura do apartamento funcional.' },
//   { id: 'RQ-004', name: 'Fornecimento de filtro de linha.' },
//   { id: 'RQ-005', name: 'Limpeza nos filtros do ar-condicionado.' },
//   { id: 'OS-001', name: 'Manutenção no grupo motor gerador.' },
//   { id: 'OS-002', name: 'Troca de óleo dos motores.' },
//   { id: 'OS-003', name: 'Troca das válvulas das bombas.' },
//   { id: 'OS-004', name: 'Troca de disjuntores na cozinha.' },
//   { id: 'OS-005', name: 'Conserto de tomadas na cozinha.' },
// ];

const ordersQuery = gql`
        query MyQuery {
          allOrders (orderBy: ORDER_ID_ASC){
            edges {
              node {
                orderId
                requestText
              }
            }
          }
          allFacilities (orderBy: ASSET_ID_ASC){
            edges {
              node {
                assetId
                name
              }
            }
          }
        }`;

class OrderForm extends Component {
  constructor(props) {
    super(props);
    this.state = {
      activeTab: '1',
    };

    this.toggle = this.toggle.bind(this);
  }

  toggle(tab) {
    if (this.state.activeTab !== tab) {
      this.setState({
        activeTab: tab,
      });
    }
  }

  render() {
    return(
      <Query query={ordersQuery}>{
        ({loading, error, data}) => {
          if(loading) return null
          if(error){
            console.log("Erro ao tentar baixar os dados!");
            return null
          }
          const orderID = data.allOrders.edges.map((item) => item.node.orderId);
          const orderText = data.allOrders.edges.map((item) => item.node.requestText);

          const facilityID = data.allFacilities.edges.map((item) => item.node.assetId);
          const facilityName = data.allFacilities.edges.map((item) => item.node.name);
          //console.log(orderID);
          //console.log(orderText);

          const orders = [];
          for(let i = 0; i<orderID.length; i++)
            orders.push({id: orderID[i], name: orderText[i]});

          const facilities = [];
          for(let i = 0; i<facilityID.length; i++)
            facilities.push({id: facilityID[i], name: facilityName[i]});

          return (
            <div style={{ margin: "0 100px" }}>
              <AssetCard
                sectionName={"Nova Ordem de Serviço"}
                sectionDescription={"Formulário para cadastro de ordem de serviço"}
                handleCardButton={() => console.log('Handle Card')}
                buttonName={"Botão"}
                isForm={true}
              >
                <Nav tabs style={{ borderBottom: "2px solid #c8ced3" }}>
                  <NavItem>
                    <NavLink
                      className={this.state.activeTab === '1' ? 'active' : ''}
                      onClick={() => { this.toggle('1'); }}
                    >
                      Ordem de Serviço
                    </NavLink>
                  </NavItem>
                  <NavItem>
                    <NavLink
                      className={this.state.activeTab === '2' ? 'active' : ''}
                      onClick={() => { this.toggle('2'); }}
                    >
                      Localização / Ativos da OS
                    </NavLink>
                  </NavItem>
                  <NavItem>
                    <NavLink
                      className={this.state.activeTab === '3' ? 'active' : ''}
                      onClick={() => { this.toggle('3'); }}
                    >
                      Informações do Solicitante
                    </NavLink>
                  </NavItem>
                </Nav>
                <TabContent activeTab={this.state.activeTab} style={{ border: 'none' }}>
                  <TabPane tabId="1">
                    <Form className="form-horizontal">
                      <FormGroup row>
                        <Col xs={'12'}>
                          <FormGroup>
                            <Label htmlFor="order-title">Título</Label>
                            <Input type="text" id="order-title" placeholder="Título da ordem de serviço" />
                          </FormGroup>
                        </Col>
                      </FormGroup>
                      <FormGroup row>
                        <Col xs={'4'}>
                          <FormGroup>
                            <SingleInputWithDropDown
                              label={'Status'}
                              placeholder="Situação da OS"
                              listDropdown={ORDER_STATUS}
                            />
                          </FormGroup>
                        </Col>
                        <Col xs={'4'}>
                          <FormGroup>
                            <SingleInputWithDropDown
                              label={'Prioridade'}
                              placeholder="Prioridade da OS"
                              listDropdown={ORDER_PRIORITY}
                            />
                          </FormGroup>
                        </Col>
                        <Col xs={'4'}>
                          <FormGroup>
                            <SingleInputWithDropDown
                              label={'Categoria'}
                              placeholder="Categoria da OS"
                              listDropdown={ORDER_CATEGORY}
                            />
                          </FormGroup>
                        </Col>
                      </FormGroup>
                      <FormGroup row>
                        <Col>
                          <FormGroup>
                            <Label htmlFor="description">Descrição</Label>
                            <Input type="textarea" id="description" placeholder="Descrição da ordem de serviço" rows="4" />
                          </FormGroup>
                        </Col>
                      </FormGroup>
                      <FormGroup row>
                        <Col xs={'4'}>
                          <FormGroup>
                            <Label htmlFor="initial-date">Data Inicial</Label>
                            <Input type="date" id="initial-date" placeholder="Início da execução" />
                          </FormGroup>
                        </Col>
                        <Col xs={'4'}>
                          <FormGroup>
                            <Label htmlFor="final-date">Data Final (Prazo)</Label>
                            <Input type="date" id="final-date" placeholder="Prazo final para execução" />
                          </FormGroup>
                        </Col>
                        <Col xs={'4'}>
                          <FormGroup>
                            <Label htmlFor="accomplished">Executado (%)</Label>
                            <Input type="text" id="accomplished" placeholder="Título da ordem de serviço" />
                          </FormGroup>
                        </Col>
                      </FormGroup>
                      <FormGroup row>
                        <Col xs={'8'}>
                          <FormGroup>
                            <SingleInputWithDropDown
                              label={'OS pai'}
                              placeholder="Nível superior da localização ..."
                              listDropdown={orders}
                            />
                          </FormGroup>
                        </Col>
                      </FormGroup>
                    </Form>
                  </TabPane>
                  <TabPane tabId="2">
                    <Form className="form-horizontal">
                      <FormGroup row>
                        <Col xs={'8'}>
                          <FormGroup>
                            <InputWithDropdown
                              label={'Ativos'}
                              placeholder={'Ativos alvos da manutenção ...'}
                              listDropdown={facilities}
                            />
                          </FormGroup>
                        </Col>
                      </FormGroup>
                      <FormGroup row>
                        <Col xs='8'>
                          <InputWithDropdown
                            label={'Localização'}
                            placeholder={'Localização da manutenção ...'}
                            listDropdown={facilities}
                          />
                        </Col>
                      </FormGroup>
                    </Form>
                  </TabPane>
                  <TabPane tabId="3">
                    <Form className="form-horizontal">
                      <FormGroup row>
                        <Col xs='6'>
                          <FormGroup>
                            <Label htmlFor="request_person">Nome do Solicitante</Label>
                            <Input type="text" id="request_person" placeholder="Pessoa que abriu a solicitação" />
                          </FormGroup>
                        </Col>
                        <Col xs='6'>
                          <FormGroup>
                            <Label htmlFor="request_department">Departamento do colicitante</Label>
                            <Input type="text" id="request_department" placeholder="Departamento da pessoa que abriu a solicitação" />
                          </FormGroup>
                        </Col>
                      </FormGroup>
                      <FormGroup row>
                        <Col xs='6'>
                          <FormGroup>
                            <Label htmlFor="request_contact_name">Nome do contato</Label>
                            <Input type="text" id="request_contact_name" placeholder="Contato para a solicitação" />
                          </FormGroup>
                        </Col>
                        <Col xs='6'>
                          <FormGroup>
                            <Label htmlFor="request_contact_phone">Telefone para contato</Label>
                            <Input type="text" id="request_contact_phone" placeholder="Telefone para contato" />
                          </FormGroup>
                        </Col>
                      </FormGroup>
                      <FormGroup row>
                        <Col xs='8'>
                          <FormGroup>
                            <Label htmlFor="request_contact_email">Email para contato</Label>
                            <Input type="text" id="request_contact_email" placeholder="Email para contato" />
                          </FormGroup>
                        </Col>
                      </FormGroup>
                    </Form>
                  </TabPane>
                </TabContent>
              </AssetCard>
            </div>
        )}}</Query>
    );
  }
}

export default withRouter(OrderForm);