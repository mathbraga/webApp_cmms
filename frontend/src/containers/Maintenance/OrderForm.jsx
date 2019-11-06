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
import { InMemoryCache } from 'apollo-cache-inmemory';

const ORDER_STATUS = [
  { id: 'FIL', text: 'Fila de espera', subtext: "" },
  { id: 'EXE', text: 'Em execução', subtext: "" },
  { id: 'CON', text: 'Concluído', subtext: "" },
  { id: 'CAN', text: 'Cancelado', subtext: "" },
  { id: 'NEG', text: 'Negado', subtext: "" },
  { id: 'PEN', text: 'Pendente', subtext: "" },
  { id: 'SUS', text: 'Suspenso', subtext: "" },
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
          allOrders(orderBy: ORDER_ID_ASC) {
            edges {
              node {
                orderId
                title
              }
            }
          }
          allAssets(orderBy: ASSET_SF_ASC) {
            edges {
              node {
                assetSf
                assetId
                name
              }
            }
          }
        }`;

const osQuery = gql`
      query WorkOrderQuery {
        allOrders(orderBy: ORDER_ID_ASC) {
          edges {
            node {
              category
              createdBy
              status
              description
              orderId
              createdAt
              dateLimit
              title
              place
              priority
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
      progress: null,
      parent: null,
      assetsArray: null,
      createdBy: null,
      place: null,
      departmentId: null,
      contactName: null,
      contactPhone: null,
      contactEmail: null
    };

    this.toggle = this.toggle.bind(this);
    this.handleStatusDropDownChange = this.handleStatusDropDownChange.bind(this);
    this.handlePriorityDropDownChange = this.handlePriorityDropDownChange.bind(this);
    this.handleCategoryDropDownChange = this.handleCategoryDropDownChange.bind(this);
    this.handleParentDropDownChange = this.handleParentDropDownChange.bind(this);
    this.handleInputChange = this.handleInputChange.bind(this);
    this.handleAssetsDropDownChange = this.handleAssetsDropDownChange.bind(this);
    // this.handleDepartmentDropDownChange = this.handleDepartmentDropDownChange.bind(this);
  }

  toggle(tab) {
    if (this.state.activeTab !== tab) {
      this.setState({
        activeTab: tab,
      });
    }
  }

  handleStatusDropDownChange(status) {
    this.setState({ status: status });
  }

  handlePriorityDropDownChange(priority) {
    this.setState({ priority: priority });
  }

  handleCategoryDropDownChange(category) {
    this.setState({ category: category });
  }

  handleParentDropDownChange(parent) {
    this.setState({ parent: parent });
  }

  // handleDepartmentDropDownChange(departmentId) {
  //   this.setState({ departmentId: departmentId });
  // }

  handleAssetsDropDownChange(assetsArray) {
    this.setState({ assetsArray: assetsArray });
  }

  handleInputChange(event) {
    if (event.target.value.length === 0)
      return this.setState({ [event.target.name]: null });
    this.setState({ [event.target.name]: event.target.value });
  }

  render() {
    const newWorkOrder = gql`
      mutation MyMutation (
        $status: OrderStatusType!,
        $priority: OrderPriorityType!,
        $category: OrderCategoryType!,
        $title: String!,
        $dateStart: Datetime,
        $dateLimit: Datetime,
        $dateEnd: Datetime,
        $parent: Int,
        $createdBy: String!,
        $description: String!,
        $progress: Int,
        $place: String,
        $contactEmail: String!,
        $contactName: String!,
        $contactPhone: String!,
        $departmentId: String!,
        $assetsArray: [Int!]!,
        $contractId: Int
        ){
          insertOrder(
            input: {
              orderAttributes: {
                status: $status
                priority: $priority
                category: $category
                title: $title
                description: $description
                departmentId: $departmentId
                createdBy: $createdBy
                contactName: $contactName
                contactPhone: $contactPhone
                contactEmail: $contactEmail
                progress: $progress
                contractId: $contractId
                dateEnd: $dateEnd
                dateLimit: $dateLimit
                dateStart: $dateStart
                place: $place
                parent: $parent
              }
              assetsArray: $assetsArray
            }
          ) {
            newOrderId
          }
    }`;

    const mutate = (newData) => (
      newData().then(console.log("Mutation"))
    )
    const assetsArray = this.state.assetsArray === null ? null : this.state.assetsArray.map((item) => item.id);
    // const parentAssets = this.state.assetsArray === null ? null : this.state.assetsArray;

    return (
      <Mutation
        mutation={newWorkOrder}
        variables={{
          status: this.state.status,
          priority: this.state.priority,
          category: this.state.category,
          title: this.state.title,
          dateStart: this.state.dateStart,
          dateLimit: this.state.dateLimit,
          parent: parseInt(this.state.parent),
          createdBy: this.state.createdBy,
          description: this.state.description,
          progress: parseInt(this.state.progress),
          contactEmail: this.state.contactEmail,
          place: this.state.place,
          contactName: this.state.contactName,
          contactPhone: this.state.contactPhone,
          departmentId: this.state.departmentId,
          assetsArray: assetsArray
        }}
        update={(cache, { data: { insertOrder } }) => {
          try{
            const listData = cache.readQuery({ query: osQuery });

            const id = insertOrder.newOrderId;
            const category = this.state.category;
            const dateStart = this.state.dateStart;
            const dateLimit = this.state.dateLimit;
            const priority = this.state.priority;
            const place = this.state.place;
            const createdBy = this.state.createdBy;
            const description = this.state.description;
            const title = this.state.title;
            const status = this.state.status;

            // const newEdges = []
            // parentAssets.forEach(item => {
            //           newEdges.push(
            //           {node: {
            //             assetByAssetId: {
            //               assetByPlace: {
            //                 assetId: item.id,
            //                 name: item.text,
            //                 __typename: "Asset"
            //               },
            //               __typename: "Asset"
            //             },
            //             __typename: "OrderAsset"
            //           },
            //           __typename: "OrderAssetsEdge"
            //           })
            //       });

            listData.allOrders.edges.push(
              {node: {
                category: category,
                createdBy: createdBy,
                status: status,
                description: description,
                orderId: id,
                createdAt: dateStart,
                dateLimit: dateLimit,
                title: title,
                place: place,
                priority: priority,
                __typename: "Order"
              },
              __typename: "OrdersEdge"
            })

            cache.writeQuery({
              query: osQuery,
              data: listData
            })
          }
          catch(error){
            console.error(error);
          }
        }}
      >
        {(mutation, { data, loading, error }) => {
          if (loading) return null;
          if (error) {
            console.log(error.message);
            return null;
          }
          return (
            <Query query={ordersQuery}>{
              ({ loading, error, data }) => {
                if (loading) return null
                if (error) {
                  console.log("Erro ao tentar baixar os dados!");
                  return null
                }

                const orderID = data.allOrders.edges.map((item) => item.node.orderId);
                const orderText = data.allOrders.edges.map((item) => item.node.title);
                
                const assetId = data.allAssets.edges.map((item) => item.node.assetId);
                const assetSf = data.allAssets.edges.map((item) => item.node.assetSf);
                const assetName = data.allAssets.edges.map((item) => item.node.name);
                //console.log(orderID);
                //console.log(orderText);

                // const departments = data.allDepartments.nodes.map(item => {
                //   return {
                //     id: item.departmentId,
                //     text: item.fullName,
                //     subtext: item.departmentId
                //   };
                // });

                const orders = [];
                for (let i = 0; i < orderID.length; i++)
                  orders.push({ id: orderID[i], text: "OS " + orderID[i] + " - " + orderText[i], subtext: "" });

                const assets = [];
                for (let i = 0; i < assetId.length; i++)
                  assets.push({ id: assetId[i], text: assetName[i], subtext: assetSf[i] });

                return (
                  <div style={{ margin: "0 100px" }}>
                    <Form
                      className="form-horizontal"
                      onSubmit={e => {
                        e.preventDefault();
                        mutate(mutation).then(() => {
                          this.props.history.push('/manutencao/os');
                        });
                      }}
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
                                  <Label htmlFor="title">Título</Label>
                                  <Input
                                    // autoComplete="new-password"
                                    onChange={this.handleInputChange}
                                    name={"title"} type="text" id={"title"} placeholder="Título da ordem de serviço"
                                    // required
                                  />
                                </FormGroup>
                              </Col>
                            </FormGroup>
                            <FormGroup row>
                              <Col xs={'4'}>
                                <FormGroup>
                                  <SingleInputWithDropDown
                                    name={'status'}
                                    label={'Status'}
                                    placeholder="Situação da OS"
                                    listDropdown={ORDER_STATUS}
                                    update={this.handleStatusDropDownChange}
                                    id={'status'}
                                    // required
                                  />
                                </FormGroup>
                              </Col>
                              <Col xs={'4'}>
                                <FormGroup>
                                  <SingleInputWithDropDown
                                    label={'Prioridade'}
                                    placeholder="Prioridade da OS"
                                    listDropdown={ORDER_PRIORITY}
                                    name={'priority'}
                                    update={this.handlePriorityDropDownChange}
                                    id={'priority'}
                                    // required
                                  />
                                </FormGroup>
                              </Col>
                              <Col xs={'4'}>
                                <FormGroup>
                                  <SingleInputWithDropDown
                                    label={'Categoria'}
                                    name='category'
                                    placeholder="Categoria da OS"
                                    listDropdown={ORDER_CATEGORY}
                                    update={this.handleCategoryDropDownChange}
                                    id={'category'}
                                    // required
                                  />
                                </FormGroup>
                              </Col>
                            </FormGroup>
                            <FormGroup row>
                              <Col>
                                <FormGroup>
                                  <Label htmlFor="description">Descrição</Label>
                                  <Input
                                    // autoComplete="new-password"
                                    onChange={this.handleInputChange}
                                    name="description" type="textarea" id="description" placeholder="Descrição da ordem de serviço" rows="4"
                                    // required
                                  />
                                </FormGroup>
                              </Col>
                            </FormGroup>
                            <FormGroup row>
                              <Col xs={'4'}>
                                <FormGroup>
                                  <Label htmlFor="initial-date">Data Inicial</Label>
                                  <Input
                                    // autoComplete="new-password"
                                    onChange={this.handleInputChange}
                                    name="dateStart" type="date" id="initial-date" placeholder="Início da execução"
                                  />
                                </FormGroup>
                              </Col>
                              <Col xs={'4'}>
                                <FormGroup>
                                  <Label htmlFor="final-date">Data Final (Prazo)</Label>
                                  <Input
                                    // autoComplete="new-password"
                                    onChange={this.handleInputChange}
                                    name="dateLimit" type="date" id="final-date" placeholder="Prazo final para execução" />
                                </FormGroup>
                              </Col>
                              <Col xs={'4'}>
                                <FormGroup>
                                  <Label htmlFor="progress">Executado (%)</Label>
                                  <Input
                                    // autoComplete="new-password"
                                    onChange={this.handleInputChange}
                                    name={"progress"} type="text" id="progress" placeholder="%" />
                                </FormGroup>
                              </Col>
                            </FormGroup>
                            <FormGroup row>
                              <Col xs={'8'}>
                                <FormGroup>
                                  <SingleInputWithDropDown
                                    label={'OS pai'}
                                    placeholder="O.S. pai"
                                    listDropdown={orders}
                                    update={this.handleParentDropDownChange}
                                    id={'order-parent'}
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
                                    id={'assets'}
                                    // required
                                  />
                                </FormGroup>
                              </Col>
                            </FormGroup>
                            <FormGroup row>
                              <Col xs='8'>
                                <Label htmlFor="place">Localização (campo livre)</Label>
                                <Input
                                  // autoComplete="new-password"
                                  onChange={this.handleInputChange}
                                  name={"place"} type="text" id="place" placeholder="Localização da manutenção ..."
                                  // required
                                />
                                {/* <InputWithDropdown
                                  label={'Localização'}
                                  placeholder={'Localização da manutenção ...'}
                                  listDropdown={assets}
                                  update={() => console.log()}
                                  id={'location'}
                                /> */}
                              </Col>
                            </FormGroup>
                          </TabPane>
                          <TabPane tabId="3">
                            <FormGroup row>
                              <Col xs='6'>
                                <FormGroup>
                                  <Label htmlFor="createdBy">Nome do Solicitante</Label>
                                  <Input
                                    // autoComplete="new-password"
                                    onChange={this.handleInputChange}
                                    name={"createdBy"} type="text" id="createdBy" placeholder="Pessoa que abriu a solicitação"
                                    // required
                                  />
                                </FormGroup>
                              </Col>
                              <Col xs='6'>
                              <Col xs='6'>
                                <FormGroup>
                                  <Label htmlFor="departmentId">Nome do contato</Label>
                                  <Input
                                    // autoComplete="new-password"
                                    onChange={this.handleInputChange}
                                    name={"departmentId"} type="text" id="departmentId" placeholder="Departamento"
                                    // required
                                  />
                                </FormGroup>
                              </Col>
                              </Col>
                            </FormGroup>
                            <FormGroup row>
                              <Col xs='6'>
                                <FormGroup>
                                  <Label htmlFor="contactName">Nome do contato</Label>
                                  <Input
                                    // autoComplete="new-password"
                                    onChange={this.handleInputChange}
                                    name={"contactName"} type="text" id="contactName" placeholder="Contato para a solicitação"
                                    // required
                                  />
                                </FormGroup>
                              </Col>
                              <Col xs='6'>
                                <FormGroup>
                                  <Label htmlFor="contactPhone">Telefone para contato</Label>
                                  <Input
                                    // autoComplete="new-password"
                                    onChange={this.handleInputChange}
                                    name={"contactPhone"} type="text" id="contactPhone" placeholder="Telefone para contato"
                                    // required
                                  />
                                </FormGroup>
                              </Col>
                            </FormGroup>
                            <FormGroup row>
                              <Col xs='8'>
                                <FormGroup>
                                  <Label htmlFor="contactEmail">Email para contato</Label>
                                  <input type="text" autoComplete="off" style={{ display: "none" }}></input>
                                  <Input
                                    // autoComplete="new-password"
                                    onChange={this.handleInputChange}
                                    name={"contactEmail"} type="text" id="contactEmail" placeholder="Email para contato"
                                    // required
                                  />
                                </FormGroup>
                              </Col>
                            </FormGroup>
                          </TabPane>
                        </TabContent>
                      </AssetCard>
                    </Form>
                  </div>
                )
              }}</Query>
          )
        }}</Mutation>
    );
  }
}

export default withRouter(OrderForm);