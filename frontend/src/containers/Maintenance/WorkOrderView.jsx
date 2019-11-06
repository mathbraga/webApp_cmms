import React, { Component } from "react";
import getWorkOrder from "../../utils/maintenance/getWorkOrder";
import AssetCard from "../../components/Cards/AssetCard";
import {
  Row,
  Col,
  Button,
  Badge,
  Nav,
  NavItem,
  NavLink,
  TabContent,
  TabPane,
  CustomInput,
  InputGroup,
  Input,
  InputGroupAddon,
  InputGroupText,
} from "reactstrap";
import '../Assets/AssetInfo.css';
import TableWithPages from "../../components/Tables/TableWithPages";

import { Query } from 'react-apollo';
import gql from 'graphql-tag';

import searchList from "../../utils/search/searchList";

const descriptionImage = require("../../assets/img/test/order_picture.png");

const searchItem = require("../../assets/icons/search_icon.png");

const ENTRIES_PER_PAGE = 15;

const attributes = [
  'assetByAssetId.name',
  'assetByAssetId.assetSf',
  'assetByAssetId.place'
]

const tableConfig = [
  { name: "Equipamento / Ativo", style: { width: "300px" }, className: "text-justifyr" },
  { name: "Localização", style: { width: "200px" }, className: "text-center" },
];

const tableConfig2 = [
  { name: "Código no contrato", style: { width: "50px" }, className: "text-justifyr" },
  { name: "Descrição", style: { width: "200px" }, className: "text-center" },
  { name: "Quantidade", style: { width: "50px" }, className: "text-center" },
  { name: "Unidade", style: { width: "50px" }, className: "text-center" },
  { name: "Preço unitário (R$)", style: { width: "50px" }, className: "text-center" },
  { name: "Total (R$)", style: { width: "50px" }, className: "text-center" },
];

const ORDER_CATEGORY_TYPE = {
  'EST': 'Avaliação estrutural',
  'FOR': 'Reparo em forro',
  'INF': 'Infiltração',
  'ELE': 'Instalações elétricas',
  'HID': 'Instalações hidrossanitárias',
  'MAR': 'Marcenaria',
  'PIS': 'Reparo em piso',
  'REV': 'Revestimento',
  'VED': 'Vedação espacial',
  'VID': 'Vidraçaria / Esquadria',
  'SER': 'Serralheria',
  'ARC': 'Ar-condicionado',
  'ELV': 'Elevadores',
  'EXA': 'Exaustores',
  'GRL': 'Serviços Gerais',
};

const ORDER_STATUS_TYPE = {
  'CAN': 'Cancelada',
  'NEG': 'Negada',
  'PEN': 'Pendente',
  'SUS': 'Suspensa',
  'FIL': 'Fila de espera',
  'EXE': 'Em execução',
  'CON': 'Concluída',
}

const ORDER_PRIORITY_TYPE = {
  'BAI': 'Baixa',
  'NOR': 'Normal',
  'ALT': 'Alta',
  'URG': 'Urgente',
};

class WorkOrderView extends Component {
  constructor(props) {
    super(props);
    this.state = {
      tabSelected: "info",
      pageCurrent: 1,
      goToPage: 1,
      searchTerm: "",
    };
    this.handleClickOnNav = this.handleClickOnNav.bind(this);
    this.setGoToPage = this.setGoToPage.bind(this);
    this.setCurrentPage = this.setCurrentPage.bind(this);
    this.handleChangeSearchTerm = this.handleChangeSearchTerm.bind(this);
  }

  handleClickOnNav(tabSelected) {
    this.setState({ tabSelected: tabSelected });
  }

  setGoToPage(page) {
    this.setState({ goToPage: page });
  }

  setCurrentPage(pageCurrent) {
    this.setState({ pageCurrent: pageCurrent }, () => {
      this.setState({ goToPage: pageCurrent });
    });
  }

  handleChangeSearchTerm(event) {
    this.setState({ searchTerm: event.target.value, pageCurrent: 1, goToPage: 1 });
  }

  render() {
    const { pageCurrent, goToPage, searchTerm, tabSelected } = this.state;
    const orderId = Number(this.props.location.pathname.slice(20));
    const woQueryInfo = gql`
      query ($orderId: Int!) {
        orderByOrderId(orderId: $orderId) {
          category
          status
          priority
          orderId
          place
          departmentId
          progress
          contractId
          dateEnd
          dateLimit
          dateStart
          parent
          contactEmail
          contactPhone
          createdBy
          description
          title
          orderByParent {
            title
            orderId
            priority
            status
            dateStart
            dateLimit
          }
          createdAt
          orderAssetsByOrderId {
            nodes {
              assetByAssetId {
                assetSf
                name
                category
              }
            }
          }
        }
        allOrderSuppliesDetails(condition: {orderId: $orderId}) {
          nodes {
            supplySf
            name
            qty
            unit
            bidPrice
            total
            specId
          }
        }
      }
    `;

    return (
      <Query
        query={woQueryInfo}
        variables={{ orderId: orderId }}
      >{
          ({ loading, error, data }) => {
            if (loading) return null
            if (error) {
              console.log("Erro ao tentar baixar os dados da OS!");
              return null
            }
            console.log(data)
            const supplies = data.allOrderSuppliesDetails.nodes;
            const orderInfo = data.orderByOrderId;
            const daysOfDelay = -((Date.parse(orderInfo.dateLimit) - (orderInfo.dateEnd ? Date.parse(orderInfo.dateEnd) : Date.now())) / (60000 * 60 * 24));

            const assetsByOrder = orderInfo.orderAssetsByOrderId.nodes;
            const pageLength = assetsByOrder.length;

            const filteredItems = searchList(assetsByOrder, attributes, searchTerm);

            const pagesTotal = Math.floor(pageLength / ENTRIES_PER_PAGE) + 1;
            const showItems = filteredItems.slice((pageCurrent - 1) * ENTRIES_PER_PAGE, pageCurrent * ENTRIES_PER_PAGE);

            const thead =
              (<tr>
                <th className="text-center checkbox-cell">
                  <CustomInput type="checkbox" />
                </th>
                {tableConfig.map(column => (
                  <th style={column.style} className={column.className}>{column.name}</th>))
                }
              </tr>);

            const tbody = showItems.map(item => (
              <tr
                onClick={() => { this.props.history.push('/ativos/view/' + item.assetByAssetId.assetSf) }}
              >
                <td className="text-center checkbox-cell"><CustomInput type="checkbox" /></td>
                <td>
                  <div>{item.assetByAssetId.name}</div>
                  <div className="small text-muted">{item.assetByAssetId.assetSf}</div>
                </td>
                <td className="text-center">
                  <div>{/*item.assetByAssetSf.place*/}</div>
                </td>
              </tr>));

            const thead2 =
            (<tr>
              <th className="text-center checkbox-cell">
                <CustomInput type="checkbox" />
              </th>
              {tableConfig2.map(column => (
                <th style={column.style} className={column.className}>{column.name}</th>))
              }
            </tr>);

            const tbody2 = supplies.map(item => (
              <tr
                onClick={() => { this.props.history.push('/gestao/servicos/view/' + item.specId) }}
              >
                <td className="text-center checkbox-cell"><CustomInput type="checkbox" /></td>
                <td className="text-center">
                  <div>{item.supplySf}</div>
                </td>
                <td className="text-center">
                  <div>{item.name}</div>
                </td>
                <td className="text-center">
                  <div>{item.qty}</div>
                </td>
                <td className="text-center">
                  <div>{item.unit}</div>
                </td>
                <td className="text-center">
                  <div>{item.bidPrice}</div>
                </td>
                <td className="text-center">
                  <div>{item.total}</div>
                </td>
              </tr>));

            return (
              <div className="asset-container">
                <AssetCard
                  sectionName={'Ordem de Serviço'}
                  sectionDescription={'Ficha descritiva do serviço'}
                  handleCardButton={() => this.props.history.push('/manutencao/os')}
                  buttonName={'Ordens de Serviço'}
                >
                  <Row>
                    <Col md="2" style={{ textAlign: "left" }}>
                      <div className="desc-box">
                        <div className="desc-img-container">
                          <img className="desc-image" src={descriptionImage} alt="Ar-condicionado" />
                        </div>
                        <div className="desc-status">
                          <Badge className="mr-1 desc-badge" color="success" >{ORDER_STATUS_TYPE[orderInfo.status]}</Badge>
                        </div>
                      </div>
                    </Col>
                    <Col className="flex-column" md="10">
                      <div style={{ flexGrow: "1" }}>
                        <Row>
                          <Col md="3" style={{ textAlign: "end" }}><span className="desc-name">Serviço (descrição breve)</span></Col>
                          <Col md="9" style={{ textAlign: "justify", paddingTop: "5px" }}><span>{orderInfo.requestTitle}</span></Col>
                        </Row>
                      </div>
                      <div>
                        <Row>
                          <Col md="3" style={{ display: "flex", alignItems: "center", justifyContent: "flex-end" }}><span className="desc-sub">Ordem de Serviço nº</span></Col>
                          <Col md="9" style={{ display: "flex", alignItems: "center" }}><span>{(orderInfo.orderId + "").padStart(4, "0")}</span></Col>
                        </Row>
                      </div>
                      <div>
                        <Row>
                          <Col md="3" style={{ display: "flex", alignItems: "center", justifyContent: "flex-end" }}><span className="desc-sub">Local da Intervenção</span></Col>
                          <Col md="9" style={{ display: "flex", alignItems: "center" }}><span>{orderInfo.requestLocal}</span></Col>
                        </Row>
                      </div>
                      <div>
                        <Row>
                          <Col md="3" style={{ display: "flex", alignItems: "center", justifyContent: "flex-end" }}><span className="desc-sub">Categoria</span></Col>
                          <Col md="9" style={{ display: "flex", alignItems: "center" }}><span>{ORDER_CATEGORY_TYPE[orderInfo.category]}</span></Col>
                        </Row>
                      </div>
                    </Col>
                  </Row>
                  <Row>
                    <div style={{ margin: "40px 20px 20px 20px", width: "100%" }}>
                      <Nav tabs>
                        <NavItem>
                          <NavLink onClick={() => { this.handleClickOnNav("info") }} active={tabSelected === "info"} >Informações Gerais</NavLink>
                        </NavItem>
                        <NavItem>
                          <NavLink onClick={() => { this.handleClickOnNav("location") }} active={tabSelected === "location"} >Dados do Solicitante</NavLink>
                        </NavItem>
                        <NavItem>
                          <NavLink onClick={() => { this.handleClickOnNav("maintenance") }} active={tabSelected === "maintenance"} >Ativos</NavLink>
                        </NavItem>
                        <NavItem>
                          <NavLink onClick={() => { this.handleClickOnNav("warranty") }} active={tabSelected === "warranty"} >Arquivos</NavLink>
                        </NavItem>
                        <NavItem>
                          <NavLink onClick={() => { this.handleClickOnNav("file") }} active={tabSelected === "file"} >Atribuido para</NavLink>
                        </NavItem>
                        <NavItem>
                          <NavLink onClick={() => { this.handleClickOnNav("log") }} active={tabSelected === "log"} >Histórico</NavLink>
                        </NavItem>
                        <NavItem>
                          <NavLink onClick={() => { this.handleClickOnNav("supplies") }} active={tabSelected === "log"} >Materiais e Serviços</NavLink>
                        </NavItem>
                      </Nav>
                      <TabContent activeTab={this.state.tabSelected} style={{ width: "100%" }}>
                        <TabPane tabId="info" style={{ width: "100%" }}>
                          <div className="asset-info-container">
                            <h1 className="asset-info-title">Detalhes do Serviço</h1>
                            <div className="asset-info-content">
                              <Row>
                                <Col md="6">
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Título do Serviço</div>
                                    <div className="asset-info-content-data">{orderInfo.title}</div>
                                  </div>
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Ordem de Serviço nº</div>
                                    <div className="asset-info-content-data">{(orderInfo.orderId + "").padStart(4, "0")}</div>
                                  </div>
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Categoria</div>
                                    <div className="asset-info-content-data">{ORDER_CATEGORY_TYPE[orderInfo.category]}</div>
                                  </div>
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Local</div>
                                    <div className="asset-info-content-data">{orderInfo.place}</div>
                                  </div>
                                </Col>
                                <Col md="6">
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Status</div>
                                    <div className="asset-info-content-data">{ORDER_STATUS_TYPE[orderInfo.status]}</div>
                                  </div>
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Percentual Executado</div>
                                    <div className="asset-info-content-data">{(orderInfo.completed || "0") + "% executado"}</div>
                                  </div>
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Prioridade</div>
                                    <div className="asset-info-content-data">{ORDER_PRIORITY_TYPE[orderInfo.priority]}</div>
                                  </div>
                                </Col>
                              </Row>
                              <div className="asset-info-single-container">
                                <div className="desc-sub">Descrição Técnica do Serviço</div>
                                <div className="asset-info-content-data">{orderInfo.requestText || "Não cadastrado"}</div>
                              </div>
                            </div>
                            <h1 className="asset-info-title">Prazos e Datas</h1>
                            <div className="asset-info-content">
                              <Row>
                                <Col md="6">
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Criação da OS</div>
                                    <div className="asset-info-content-data">{orderInfo.createdAt ? orderInfo.createdAt.split("T")[0] : "Não registrado"}</div>
                                  </div>
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Início da Execução</div>
                                    <div className="asset-info-content-data">{orderInfo.dateStart ? orderInfo.dateStart.split("T")[0] : "Serviço não iniciado"}</div>
                                  </div>
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Término da Execução</div>
                                    <div className="asset-info-content-data">{orderInfo.dateEnd ? orderInfo.dateEnd.split("T")[0] : "Serviço não finalizado"}</div>
                                  </div>
                                </Col>
                                <Col md="6">
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Prazo Final</div>
                                    <div className="asset-info-content-data">{orderInfo.dateLimit ? orderInfo.dateLimit.split("T")[0] : "Não registrado"}</div>
                                  </div>
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Dias de Atraso</div>
                                    <div className="asset-info-content-data">
                                      {(daysOfDelay <= 0 || isNaN(daysOfDelay)) ? "Serviço sem atraso" : Math.trunc(daysOfDelay)}
                                    </div>
                                  </div>
                                </Col>
                              </Row>
                            </div>
                            {orderInfo.orderByParent && (
                              <React.Fragment>
                                <h1 className="asset-info-title">Ordem de Serviço Pai</h1>
                                <div className="asset-info-content">
                                  <Row>
                                    <Col md="6">
                                      <div className="asset-info-single-container">
                                        <div className="desc-sub">Título do Serviço</div>
                                        <div className="asset-info-content-data">{orderInfo.orderByParent.title}</div>
                                      </div>
                                      <div className="asset-info-single-container">
                                        <div className="desc-sub">Ordem de Serviço nº</div>
                                        <div className="asset-info-content-data">{orderInfo.orderByParent.orderId.toString().padStart(4, "0")}</div>
                                      </div>
                                      <div className="asset-info-single-container">
                                        <div className="desc-sub">Status</div>
                                        <div className="asset-info-content-data">{ORDER_STATUS_TYPE[orderInfo.orderByParent.status]}</div>
                                      </div>
                                    </Col>
                                    <Col md="6">
                                      <div className="asset-info-single-container">
                                        <div className="desc-sub">Prioridade</div>
                                        <div className="asset-info-content-data">{ORDER_PRIORITY_TYPE[orderInfo.orderByParent.priority]}</div>
                                      </div>
                                      <div className="asset-info-single-container">
                                        <div className="desc-sub">Início da Execução</div>
                                        <div className="asset-info-content-data">{orderInfo.orderByParent.dateStart ? orderInfo.orderByParent.dateStart.split("T")[0] : "Serviço não iniciado"}</div>
                                      </div>
                                      <div className="asset-info-single-container">
                                        <div className="desc-sub">Prazo Final</div>
                                        <div className="asset-info-content-data">{orderInfo.orderByParent.dateLimit ? orderInfo.orderByParent.dateLimit.split("T")[0] : "Não registrado"}</div>
                                      </div>
                                    </Col>
                                  </Row>
                                </div>
                              </React.Fragment>
                            )}
                          </div>
                        </TabPane>
                        <TabPane tabId="location" style={{ width: "100%" }}>
                          <div className="asset-info-container">
                            <h1 className="asset-info-title">Solicitante</h1>
                            <div className="asset-info-content">
                              <Row>
                                <Col md="6">
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Nome do Solicitante</div>
                                    <div className="asset-info-content-data">{orderInfo.createdBy}</div>
                                  </div>
                                </Col>
                                <Col md="6">
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Departamento</div>
                                    <div className="asset-info-content-data">{orderInfo.department_id}</div>
                                  </div>
                                </Col>
                              </Row>
                            </div>
                            <h1 className="asset-info-title">Contato</h1>
                            <div className="asset-info-content">
                              <Row>
                                <Col md="6">
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Nome do Contato</div>
                                    <div className="asset-info-content-data">{orderInfo.contactName}</div>
                                  </div>
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Telefone para Contato</div>
                                    <div className="asset-info-content-data">{orderInfo.contactPhone}</div>
                                  </div>
                                </Col>
                                <Col md="6">
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">E-mail para Contato</div>
                                    <div className="asset-info-content-data">{orderInfo.contactEmail}</div>
                                  </div>
                                </Col>
                              </Row>
                            </div>
                          </div>
                        </TabPane>
                        <TabPane tabId="maintenance" style={{ width: "100%" }}>
                          <div className="asset-info-container">
                            <h1 className="asset-info-title">Lista de Ativos</h1>
                            <div className="asset-info-content">
                              <Row>
                                <Col md="6">
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Quantidade de Ativos</div>
                                    <div className="asset-info-content-data">{pageLength.toString().padStart(3, "0")}</div>
                                  </div>
                                </Col>
                              </Row>
                            </div>
                            <div className="card-search-container" style={{ marginTop: "30px" }}>
                              <div className="search" style={{ width: "30%" }}>
                                <div className="card-search-form">
                                  <InputGroup>
                                    <Input placeholder="Pesquisar ..." value={searchTerm} onChange={this.handleChangeSearchTerm} />
                                    <InputGroupAddon addonType="append">
                                      <InputGroupText><img src={searchItem} alt="" style={{ width: "19px", height: "16px", margin: "3px 0px" }} /></InputGroupText>
                                    </InputGroupAddon>
                                  </InputGroup>
                                </div>
                              </div>
                              <div className="search-filter" style={{ width: "30%" }}>
                                <ol>
                                  <li><span className="card-search-title">Filtro: </span></li>
                                  <li><span className="card-search-title">Regras: </span></li>
                                </ol>
                                <ol>
                                  <li>Sem filtro</li>
                                  <li>Mostrar todos itens</li>
                                </ol>
                              </div>
                              <div className="search-buttons" style={{ width: "30%" }}>
                                <Button className="search-filter-button" color="success">Aplicar Filtro</Button>
                                <Button className="search-filter-button" color="primary">Criar Filtro</Button>
                              </div>
                            </div>
                            <TableWithPages
                              thead={thead}
                              tbody={tbody}
                              pagesTotal={pagesTotal}
                              pageCurrent={pageCurrent}
                              goToPage={goToPage}
                              setCurrentPage={this.setCurrentPage}
                              setGoToPage={this.setGoToPage}
                            />
                          </div>
                        </TabPane>
                        <TabPane tabId="supplies" style={{ width: "100%" }}>
                          <div className="asset-info-container">
                            <h1 className="asset-info-title">Lista de materiais e serviços</h1>
                            <div className="asset-info-content">
                              <Row>
                                <Col md="6">
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Quantidade de Ativos</div>
                                    <div className="asset-info-content-data">{pageLength.toString().padStart(3, "0")}</div>
                                  </div>
                                </Col>
                              </Row>
                            </div>
                            <div className="card-search-container" style={{ marginTop: "30px" }}>
                              <div className="search" style={{ width: "30%" }}>
                                <div className="card-search-form">
                                  <InputGroup>
                                    <Input placeholder="Pesquisar ..." value={searchTerm} onChange={this.handleChangeSearchTerm} />
                                    <InputGroupAddon addonType="append">
                                      <InputGroupText><img src={searchItem} alt="" style={{ width: "19px", height: "16px", margin: "3px 0px" }} /></InputGroupText>
                                    </InputGroupAddon>
                                  </InputGroup>
                                </div>
                              </div>
                              <div className="search-filter" style={{ width: "30%" }}>
                                <ol>
                                  <li><span className="card-search-title">Filtro: </span></li>
                                  <li><span className="card-search-title">Regras: </span></li>
                                </ol>
                                <ol>
                                  <li>Sem filtro</li>
                                  <li>Mostrar todos itens</li>
                                </ol>
                              </div>
                              <div className="search-buttons" style={{ width: "30%" }}>
                                <Button className="search-filter-button" color="success">Aplicar Filtro</Button>
                                <Button className="search-filter-button" color="primary">Criar Filtro</Button>
                              </div>
                            </div>
                            <TableWithPages
                              thead={thead2}
                              tbody={tbody2}
                              pagesTotal={'1'}
                              pageCurrent={'1'}
                              goToPage={''}
                              setCurrentPage={''}
                              setGoToPage={''}
                            />
                          </div>
                        </TabPane>
                        <TabPane tabId="warranty" style={{ width: "100%" }}>
                          <div>
                            Garantias.
                          </div>
                        </TabPane>
                        <TabPane tabId="asset" style={{ width: "100%" }}>
                          <div>
                            Lista de ativo.
                          </div>
                        </TabPane>
                        <TabPane tabId="file" style={{ width: "100%" }}>
                          <div>
                            Lista de arquivos.
                         </div>
                        </TabPane>
                        <TabPane tabId="log" style={{ width: "100%" }}>
                          <div>
                            Histórico sobre o equipamento.
                          </div>
                        </TabPane>
                      </TabContent>
                    </div>
                  </Row>
                </AssetCard>
              </div>
            )
          }}</Query>
    );
  }
}

export default WorkOrderView;
