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
import { Query, Mutation } from 'react-apollo';
import gql from 'graphql-tag';

const ORDER_STATUS = [
  { id: 'CAN', text: 'Cancelado', subtext: "" },
  { id: 'NEG', text: 'Negado', subtext: "" },
  { id: 'PEN', text: 'Pendente', subtext: "" },
  { id: 'SUS', text: 'Suspenso', subtext: "" },
  { id: 'FIL', text: 'Fila de espera', subtext: "" },
  { id: 'EXE', text: 'Em execução', subtext: "" },
  { id: 'CON', text: 'Concluído', subtext: "" },
];

const ORDER_PRIORITY = [
  { id: 'BAI', text: 'Baixa', subtext: "" },
  { id: 'NOR', text: 'Normal', subtext: "" },
  { id: 'ALT', text: 'Alta', subtext: "" },
  { id: 'URG', text: 'Urgente', subtext: "" },
];

const ORDER_CATEGORY = [
  { id: 'EST', text: 'Avaliação Estrutural', subtext: "" },
  { id: 'FOR', text: 'Reparo em Forro', subtext: "" },
  { id: 'INF', text: 'Infiltração', subtext: "" },
  { id: 'ELE', text: 'Instalações Elétricas', subtext: "" },
  { id: 'HID', text: 'Instalações Hidrossanitárias', subtext: "" },
  { id: 'MAR', text: 'Marcenaria', subtext: "" },
  { id: 'PIS', text: 'Reparo em Piso', subtext: "" },
  { id: 'REV', text: 'Revestimento', subtext: "" },
  { id: 'VED', text: 'Vedação Espacial', subtext: "" },
  { id: 'VID', text: 'Vidraçaria/Esquadria', subtext: "" },
  { id: 'SER', text: 'Serralheria', subtext: "" },
];

// const assets = [
//   { id: 'ACAT-001-001', name: 'Ar condicionado - Midea' },
//   { id: 'AFDE-001-001', name: 'Casa de máquinas' },
//   { id: 'QDEL-001-001', name: 'Quadro de energia elétrica - Sinfra' },
//   { id: 'QDEL-001-002', name: 'Quadro de energia elétrica - Coemant' },
//   { id: 'QDEL-001-003', name: 'Quadro de energia elétrica - Seplag' },
//   { id: 'GMG1-001-001', name: 'Grupo motor gerador - Painel' },
//   { id: 'GMG1-001-002', name: 'Grupo motor gerador - Motor' },
//   { id: 'GMG1-002-003', name: 'Grupo motor gerador - Gerador' },
//   { id: 'ANX2-001-001', name: 'Anexo 2 - Rui Barbosa' },
//   { id: 'ANX2-002-001', name: 'Anexo 2 - Petrônio Portela' },
//   { id: 'ANX2-003-001', name: 'Anexo 2 - Auditório' },
//   { id: 'ANX1-001-001', name: 'Anexo 1 - Pavimento 01' },
//   { id: 'ANX1-002-001', name: 'Anexo 1 - Pavimento 02' },
//   { id: 'ANX1-003-001', name: 'Anexo 1 - Pavimento 03' },
//   { id: 'ANX1-004-001', name: 'Anexo 1 - Pavimento 04' },
// ];

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
          allAssets (orderBy: ASSET_ID_ASC){
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
      title: null,
      status: null,
      priority: null,
      category: null,
      description: null,
      dateStart: null,
      dateLimit: null,
      execution: null,
      parent: null,
      assets: null,
      requestPerson: null,
      requestDepartment: null,
      requestContactName: null,
      requestContactPhone: null,
      requestContactEmail: null
    };

    this.toggle = this.toggle.bind(this);
    this.handleStatusDropDownChange = this.handleStatusDropDownChange.bind(this);
    this.handlePriorityDropDownChange = this.handlePriorityDropDownChange.bind(this);
    this.handleCategoryDropDownChange = this.handleCategoryDropDownChange.bind(this);
    this.handleParentDropDownChange = this.handleParentDropDownChange.bind(this);
    this.handleInputChange = this.handleInputChange.bind(this);
    this.handleAssetsDropDownChange = this.handleAssetsDropDownChange.bind(this);
  }

  toggle(tab) {
    if (this.state.activeTab !== tab) {
      this.setState({
        activeTab: tab,
      });
    }
  }

  handleStatusDropDownChange(status){
    this.setState({ status: status });
  }

  handlePriorityDropDownChange(priority){
    this.setState({ priority: priority });
  }

  handleCategoryDropDownChange(category){
    this.setState({ category: category });
  }

  handleParentDropDownChange(parent){
    this.setState({ parent: parent });
  }

  handleAssetsDropDownChange(assets){
    this.setState({ assets: assets });
  }

  handleInputChange(event){
    if(event.target.value.length === 0)
      return this.setState({ [event.target.name]: null });
    this.setState({ [event.target.name]: event.target.value });
  }

  render() {
    console.log(this.state)
    const newWorkOrder = gql`
      mutation MyMutation (
        $status: OrderStatusType!,
        $priority: OrderPriorityType!,
        $category: OrderCategoryType!,
        $requestTitle: String!,
        $dateStart: Datetime,
        $dateLimit: Datetime,
        $parent: Int,
        $requestPerson: String!,
        $requestText: String!,
        $completed: Int,
        $requestContactEmail: String!,
        $requestContactName: String!,
        $requestContactPhone: String!,
        $requestDepartment: String!,
        $assetsArray: [String]!
        ){
          insertOrder(
            input: {
              orderAttributes: {
                status: $status
                priority: $priority
                category: $category
                requestTitle: $requestTitle
                dateStart: $dateStart
                dateLimit: $dateLimit
                parent: $parent
                requestPerson: $requestPerson
                requestText: $requestText
                completed: $completed
                requestContactEmail: $requestContactEmail
                requestContactName: $requestContactName
                requestContactPhone: $requestContactPhone
                requestDepartment: $requestDepartment
              }
              assetsArray: $assetsArray
            }
          ) {
            clientMutationId
            integer
          }
    }`;

    const mutate = (newData) => (
      newData().then(console.log("Mutation"))
    )
    const assetsArray = this.state.assets === null ? null : this.state.assets.map((item) => item.id);
    
    return(
      <Mutation 
        mutation={newWorkOrder}
        variables={{
          status: this.state.status,
          priority: this.state.priority,
          category: this.state.category,
          requestTitle: this.state.title,
          dateStart: this.state.dateStart,
          dateLimit: this.state.dateLimit,
          parent: parseInt(this.state.parent),
          requestPerson: this.state.requestPerson,
          requestText: this.state.description,
          completed: parseInt(this.state.execution),
          requestContactEmail: this.state.requestContactEmail,
          requestContactName: this.state.requestContactName,
          requestContactPhone: this.state.requestContactPhone,
          requestDepartment: this.state.requestDepartment,
          assetsArray: assetsArray
        }}
      >
      {(mutation, {data, loading, error}) => {
        if (loading) return null;
        if(error){
          console.log(error);
          return null;
        }
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

            const assetId = data.allAssets.edges.map((item) => item.node.assetId);
            const assetName = data.allAssets.edges.map((item) => item.node.name);
            //console.log(orderID);
            //console.log(orderText);

            const orders = [];
            for(let i = 0; i<orderID.length; i++)
              orders.push({id: orderID[i], text: "OS " + orderID[i] + " - " + orderText[i], subtext: ""});

            const assets = [];
            for(let i = 0; i<assetId.length; i++)
              assets.push({id: assetId[i], text: assetName[i], subtext: assetId[i]});

            return (
              <div style={{ margin: "0 100px" }}>
              <Form 
                className="form-horizontal"
                onSubmit={e => {
                  e.preventDefault();
                  mutate(mutation)}}
                onReset={() => this.props.history.push('/manutencao/os')}
              >
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
                        <FormGroup row>
                          <Col xs={'12'}>
                            <FormGroup>
                              <Label htmlFor="order-title">Título</Label>
                              <Input 
                                onChange={this.handleInputChange}
                                name="title" type="text" id="order-title" placeholder="Título da ordem de serviço" />
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
                                update={this.handleStatusDropDownChange}
                              />
                            </FormGroup>
                          </Col>
                          <Col xs={'4'}>
                            <FormGroup>
                              <SingleInputWithDropDown
                                label={'Prioridade'}
                                placeholder="Prioridade da OS"
                                listDropdown={ORDER_PRIORITY}
                                update={this.handlePriorityDropDownChange}
                              />
                            </FormGroup>
                          </Col>
                          <Col xs={'4'}>
                            <FormGroup>
                              <SingleInputWithDropDown
                                label={'Categoria'}
                                placeholder="Categoria da OS"
                                listDropdown={ORDER_CATEGORY}
                                update={this.handleCategoryDropDownChange}
                              />
                            </FormGroup>
                          </Col>
                        </FormGroup>
                        <FormGroup row>
                          <Col>
                            <FormGroup>
                              <Label htmlFor="description">Descrição</Label>
                              <Input 
                                onChange={this.handleInputChange}
                                name="description" type="textarea" id="description" placeholder="Descrição da ordem de serviço" rows="4" />
                            </FormGroup>
                          </Col>
                        </FormGroup>
                        <FormGroup row>
                          <Col xs={'4'}>
                            <FormGroup>
                              <Label htmlFor="initial-date">Data Inicial</Label>
                              <Input 
                                onChange={this.handleInputChange}
                                name="dateStart" type="date" id="initial-date" placeholder="Início da execução" />
                            </FormGroup>
                          </Col>
                          <Col xs={'4'}>
                            <FormGroup>
                              <Label htmlFor="final-date">Data Final (Prazo)</Label>
                              <Input 
                                onChange={this.handleInputChange}
                                name="dateLimit" type="date" id="final-date" placeholder="Prazo final para execução" />
                            </FormGroup>
                          </Col>
                          <Col xs={'4'}>
                            <FormGroup>
                              <Label htmlFor="accomplished">Executado (%)</Label>
                              <Input 
                                onChange={this.handleInputChange}
                                name="execution" type="text" id="accomplished" placeholder="Título da ordem de serviço" />
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
                                update={this.handleParentDropDownChange}
                              />
                            </FormGroup>
                          </Col>
                        </FormGroup>
                    </TabPane>
                    <TabPane tabId="2">
                        <FormGroup row>
                          <Col xs={'8'}>
                            <FormGroup>
                              <InputWithDropdown
                                label={'Ativos'}
                                placeholder={'Ativos alvos da manutenção ...'}
                                listDropdown={assets}
                                update={this.handleAssetsDropDownChange}
                              />
                            </FormGroup>
                          </Col>
                        </FormGroup>
                        <FormGroup row>
                          <Col xs='8'>
                            <InputWithDropdown
                              label={'Localização'}
                              placeholder={'Localização da manutenção ...'}
                              listDropdown={assets}
                              update={() => console.log()}
                            />
                          </Col>
                        </FormGroup>
                    </TabPane>
                    <TabPane tabId="3">
                        <FormGroup row>
                          <Col xs='6'>
                            <FormGroup>
                              <Label htmlFor="request_person">Nome do Solicitante</Label>
                              <Input 
                                onChange={this.handleInputChange}
                                name="requestPerson" type="text" id="request_person" placeholder="Pessoa que abriu a solicitação" />
                            </FormGroup>
                          </Col>
                          <Col xs='6'>
                            <FormGroup>
                              <Label htmlFor="request_department">Departamento do Solicitante</Label>
                              <Input 
                                onChange={this.handleInputChange}
                                name="requestDepartment" type="text" id="request_department" placeholder="Departamento da pessoa que abriu a solicitação" />
                            </FormGroup>
                          </Col>
                        </FormGroup>
                        <FormGroup row>
                          <Col xs='6'>
                            <FormGroup>
                              <Label htmlFor="request_contact_name">Nome do contato</Label>
                              <Input 
                                onChange={this.handleInputChange}
                                name="requestContactName" type="text" id="request_contact_name" placeholder="Contato para a solicitação" />
                            </FormGroup>
                          </Col>
                          <Col xs='6'>
                            <FormGroup>
                              <Label htmlFor="request_contact_phone">Telefone para contato</Label>
                              <Input 
                                onChange={this.handleInputChange}
                                name="requestContactPhone" type="text" id="request_contact_phone" placeholder="Telefone para contato" />
                            </FormGroup>
                          </Col>
                        </FormGroup>
                        <FormGroup row>
                          <Col xs='8'>
                            <FormGroup>
                              <Label htmlFor="request_contact_email">Email para contato</Label>
                              <Input 
                                onChange={this.handleInputChange}
                                name="requestContactEmail" type="text" id="request_contact_email" placeholder="Email para contato" />
                            </FormGroup>
                          </Col>
                        </FormGroup>
                    </TabPane>
                  </TabContent>
                </AssetCard>
              </Form>
              </div>
          )}}</Query>
        )}}</Mutation>
    );
  }
}

export default withRouter(OrderForm);