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

const descriptionImage = require("../../assets/img/test/item_list.png");
const searchItem = require("../../assets/icons/search_icon.png");

const ENTRIES_PER_PAGE = 15;

const tableConfig = [
  { name: "Equipamento / Ativo", style: { width: "300px" }, className: "text-justifyr" },
  { name: "Localização", style: { width: "200px" }, className: "text-center" },
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

class MaterialView extends Component {
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
    const specId = parseInt(this.props.location.pathname.slice(22), 10);
    console.log(specId);
    const specInfo = gql`
      query ($specId: Int!) {
        allBalances(condition: {specId: $specId}) {
          nodes {
            title
            supplySf
            supplyId
            specId
            qty
            fullPrice
            contractSf
            contractId
            consumed
            company
            blocked
            bidPrice
            available
          }
        }
        specBySpecId(specId: $specId) {
          version
          unit
          updatedAt
          subcategory
          spreadsheets
          specSf
          specId
          services
          qualification
          notes
          nodeId
          name
          materials
          lifespan
          isSubcont
          description
          criteria
          createdAt
          catser
          catmat
          category
          activities
        }
        allSpecOrders(condition: {specId: $specId}) {
          nodes {
            orderId
            status
            specId
            title
          }
        }
      }
    
    `;

    return (
      <Query
        query={specInfo}
        variables={{ specId: specId }}
      >{
          ({ loading, error, data }) => {
            if (loading) return null
            if (error) {
              console.log("Erro ao tentar baixar os dados da OS!");
              return null
            }
            console.log(data);

            const spec = data.specBySpecId;
            const balances =   data.allBalances.nodes;
            const orders = data.allSpecOrders.nodes;

            // const daysOfDelay = -((Date.parse(orderInfo.dateLimit) - (orderInfo.dateEnd ? Date.parse(orderInfo.dateEnd) : Date.now())) / (60000 * 60 * 24));

            // const assetsByOrder = orderInfo.orderAssetsByOrderId.nodes;
            // const pageLength = assetsByOrder.length;

            // let filteredItems = assetsByOrder;
            // if (searchTerm.length > 0) {
            //   const searchTermLower = searchTerm.toLowerCase();
            //   filteredItems = assetsByOrder.filter(function (item) {
            //     return (
            //       // item.node.orderByOrderId.category.toLowerCase().includes(searchTermLower) ||
            //       item.assetByAssetId.name.toLowerCase().includes(searchTermLower) ||
            //       item.assetByAssetId.assetId.toLowerCase().includes(searchTermLower) ||
            //       item.assetByAssetId.place.toLowerCase().includes(searchTermLower)
            //     );
            //   });
            // }

            const pagesTotal = 1;//Math.floor(pageLength / ENTRIES_PER_PAGE) + 1;
            // const showItems = filteredItems.slice((pageCurrent - 1) * ENTRIES_PER_PAGE, pageCurrent * ENTRIES_PER_PAGE);

            const thead =
              (<tr>
                <th className="text-center checkbox-cell">
                  <CustomInput type="checkbox" />
                </th>
                {tableConfig.map(column => (
                  <th style={column.style} className={column.className}>{column.name}</th>))
                }
              </tr>);

            const tbody = orders.map(item => (
              <tr
                onClick={() => { this.props.history.push('/manutencao/os/view/' + item.orderId) }}
              >
                <td className="text-center checkbox-cell"><CustomInput type="checkbox" /></td>
                <td>
                  <div>{item.title}</div>
                  <div className="small text-muted">{item.status}</div>
                </td>
                <td className="text-center">
                  <div>{item.status}</div>
                </td>
              </tr>));

            return (
              <div className="asset-container">
                <AssetCard
                  sectionName={'Materiais e Serviços'}
                  sectionDescription={'Especificações técnicas'}
                  handleCardButton={() => this.props.history.push('/gestao/servicos')}
                  buttonName={'Materiais e Serviços'}
                >
                  <Row>
                    <Col md="2" style={{ textAlign: "left" }}>
                      <div className="desc-box">
                        <div className="desc-img-container">
                          <img className="desc-image" src={descriptionImage} alt="Ar-condicionado" />
                        </div>
                        <div className="desc-status">
                          <Badge className="mr-1 desc-badge" color="success" >Disponível</Badge>
                        </div>
                      </div>
                    </Col>
                    <Col className="flex-column" md="10">
                      <div style={{ flexGrow: "1" }}>
                        <Row>
                          <Col md="3" style={{ textAlign: "end" }}><span className="desc-name">Serviço / Material</span></Col>
                          <Col md="9" style={{ textAlign: "justify", paddingTop: "5px" }}><span>Luminária 2x14 W de embutir</span></Col>
                        </Row>
                      </div>
                      <div>
                        <Row>
                          <Col md="3" style={{ display: "flex", alignItems: "center", justifyContent: "flex-end" }}><span className="desc-sub">Código</span></Col>
                          <Col md="9" style={{ display: "flex", alignItems: "center" }}><span>SF-00274</span></Col>
                        </Row>
                      </div>
                      <div>
                        <Row>
                          <Col md="3" style={{ display: "flex", alignItems: "center", justifyContent: "flex-end" }}><span className="desc-sub">Versão</span></Col>
                          <Col md="9" style={{ display: "flex", alignItems: "center" }}><span>v02 (Atualizada)</span></Col>
                        </Row>
                      </div>
                      <div>
                        <Row>
                          <Col md="3" style={{ display: "flex", alignItems: "center", justifyContent: "flex-end" }}><span className="desc-sub">Disponibilidade</span></Col>
                          <Col md="9" style={{ display: "flex", alignItems: "center" }}><span>134 unidades</span></Col>
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
                          <NavLink onClick={() => { this.handleClickOnNav("contracts") }} active={tabSelected === "contracts"} >Contratações</NavLink>
                        </NavItem>
                        <NavItem>
                          <NavLink onClick={() => { this.handleClickOnNav("workOrders") }} active={tabSelected === "workOrders"} >Ordens de Serviços</NavLink>
                        </NavItem>
                        <NavItem>
                          <NavLink onClick={() => { this.handleClickOnNav("log") }} active={tabSelected === "log"} >Histórico</NavLink>
                        </NavItem>
                      </Nav>
                      <TabContent activeTab={this.state.tabSelected} style={{ width: "100%" }}>
                        <TabPane tabId="info" style={{ width: "100%" }}>
                          <div className="asset-info-container">
                            <h1 className="asset-info-title">Especificações Técnicas</h1>
                            <div className="asset-info-content">
                              <Row>
                                <Col md="6">
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Serviço / Material</div>
                                    <div className="asset-info-content-data">{spec.name}</div>
                                  </div>
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Categoria</div>
                                    <div className="asset-info-content-data">{spec.category}</div>
                                  </div>
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Subcategoria</div>
                                    <div className="asset-info-content-data">{spec.subcategory}</div>
                                  </div>
                                </Col>
                                <Col md="6">
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Código</div>
                                    <div className="asset-info-content-data">{spec.specSf}</div>
                                  </div>
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Versão</div>
                                    <div className="asset-info-content-data">{spec.version}</div>
                                  </div>
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">CATMAT / CATSER</div>
                                    <div className="asset-info-content-data">{spec.catmat + " / " + spec.catser}</div>
                                  </div>
                                </Col>
                              </Row>
                              <div className="asset-info-single-container">
                                <div className="desc-sub">Descrição Detalhada</div>
                                <div className="asset-info-content-data">{spec.description}</div>
                              </div>
                            </div>
                            <h1 className="asset-info-title">Definição dos Serviços e Materiais</h1>
                            <div className="asset-info-content">
                              <div className="asset-info-single-container">
                                <div className="desc-sub">Detalhamento dos Materiais</div>
                                <div className="asset-info-content-data">
                                  {spec.materials}
                                </div>
                              </div>
                              <div className="asset-info-single-container">
                                <div className="desc-sub">Detalhamento dos Serviços</div>
                                <div className="asset-info-content-data">
                                  {spec.services}
                                </div>
                              </div>
                            </div>
                          </div>
                        </TabPane>
                        <TabPane tabId="contracts" style={{ width: "100%" }}>
                          <div className="asset-info-container">
                            <h1 className="asset-info-title">Saldos</h1>
                            <div className="asset-info-content">
                              
                              {balances.map(item => (
                                <div>
                                <h2>{item.company}</h2>
                                <h3>{item.contractSf + " " + item.title}</h3>
                                <ul>
                                  <li>{"Código no contrato: " + item.supplySf}</li>
                                  <li>{"Quantidade contratada: " + item.qty}</li>
                                  <li>{"Quantidade bloqueada: " + item.blocked}</li>
                                  <li>{"Quantidade consumida: " + item.consumed}</li>
                                  <li>{"Quantidade disponível: " + item.available}</li>
                                </ul>
                                </div>
                              ))}
                              
                              
                              
                            </div>
                          </div>
                        </TabPane>
                        <TabPane tabId="workOrders" style={{ width: "100%" }}>
                          <div className="asset-info-container">
                            <h1 className="asset-info-title">Lista de Ordens de Serviço</h1>
                            <div className="asset-info-content">
                              <Row>
                                <Col md="6">
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Ordens de Serviço com o Material / Serviço</div>
                                    <div className="asset-info-content-data">04</div>
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
                                  <li>Últimos 12 meses</li>
                                  <li>Fechamento nos últimos 12 meses.</li>
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
          }
        }</Query >
    );
  }
}

export default MaterialView;
