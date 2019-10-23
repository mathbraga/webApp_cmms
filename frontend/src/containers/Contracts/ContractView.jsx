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

const descriptionImage = require("../../assets/img/test/order_picture.png");

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

class ContractView extends Component {
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
    const orderId = 1;
    const woQueryInfo = gql`
      query ($orderId: Int!) {
        orderByOrderId(orderId: $orderId) {
          category
          status
          priority
          orderId
          requestLocal
          requestDepartment
          completed
          contractId
          dateEnd
          dateLimit
          dateStart
          parent
          requestContactEmail
          requestContactName
          requestContactPhone
          requestPerson
          requestText
          requestTitle
          orderByParent {
            requestTitle
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
                assetId
                name
                category
                place
                assetByPlace {
                  name
                  assetId
                }
              }
            }
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
            const orderInfo = data.orderByOrderId;
            const daysOfDelay = -((Date.parse(orderInfo.dateLimit) - (orderInfo.dateEnd ? Date.parse(orderInfo.dateEnd) : Date.now())) / (60000 * 60 * 24));

            const assetsByOrder = orderInfo.orderAssetsByOrderId.nodes;
            const pageLength = assetsByOrder.length;

            let filteredItems = assetsByOrder;
            if (searchTerm.length > 0) {
              const searchTermLower = searchTerm.toLowerCase();
              filteredItems = assetsByOrder.filter(function (item) {
                return (
                  // item.node.orderByOrderId.category.toLowerCase().includes(searchTermLower) ||
                  item.assetByAssetId.name.toLowerCase().includes(searchTermLower) ||
                  item.assetByAssetId.assetId.toLowerCase().includes(searchTermLower) ||
                  item.assetByAssetId.place.toLowerCase().includes(searchTermLower)
                );
              });
            }

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
                onClick={() => { this.props.history.push('/ativos/view/' + item.assetByAssetId.assetId) }}
              >
                <td className="text-center checkbox-cell"><CustomInput type="checkbox" /></td>
                <td>
                  <div>{item.assetByAssetId.name}</div>
                  <div className="small text-muted">{item.assetByAssetId.assetId}</div>
                </td>
                <td className="text-center">
                  <div>{item.assetByAssetId.place}</div>
                </td>
              </tr>));

            return (
              <div className="asset-container">
                <AssetCard
                  sectionName={'Contrato'}
                  sectionDescription={'Ficha descritiva do contrato'}
                  handleCardButton={() => this.props.history.push('/gestao/contratos')}
                  buttonName={'Contratos'}
                >
                  <Row>
                    <Col md="2" style={{ textAlign: "left" }}>
                      <div className="desc-box">
                        <div className="desc-img-container">
                          <img className="desc-image" src={descriptionImage} alt="Ar-condicionado" />
                        </div>
                        <div className="desc-status">
                          <Badge className="mr-1 desc-badge" color="success" >Vigente</Badge>
                        </div>
                      </div>
                    </Col>
                    <Col className="flex-column" md="10">
                      <div style={{ flexGrow: "1" }}>
                        <Row>
                          <Col md="3" style={{ textAlign: "end" }}><span className="desc-name">Objeto (descrição breve)</span></Col>
                          <Col md="9" style={{ textAlign: "justify", paddingTop: "5px" }}><span>Manutenção do Sistema Elétrico do Senado Federal</span></Col>
                        </Row>
                      </div>
                      <div>
                        <Row>
                          <Col md="3" style={{ display: "flex", alignItems: "center", justifyContent: "flex-end" }}><span className="desc-sub">Contrato nº</span></Col>
                          <Col md="9" style={{ display: "flex", alignItems: "center" }}><span>110/2019</span></Col>
                        </Row>
                      </div>
                      <div>
                        <Row>
                          <Col md="3" style={{ display: "flex", alignItems: "center", justifyContent: "flex-end" }}><span className="desc-sub">Fiscal</span></Col>
                          <Col md="9" style={{ display: "flex", alignItems: "center" }}><span>Coemant</span></Col>
                        </Row>
                      </div>
                      <div>
                        <Row>
                          <Col md="3" style={{ display: "flex", alignItems: "center", justifyContent: "flex-end" }}><span className="desc-sub">Empresa</span></Col>
                          <Col md="9" style={{ display: "flex", alignItems: "center" }}><span>RCS Tecnologia LTDA</span></Col>
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
                          <NavLink onClick={() => { this.handleClickOnNav("documents") }} active={tabSelected === "documents"} >Documentos Digitalizados</NavLink>
                        </NavItem>
                        <NavItem>
                          <NavLink onClick={() => { this.handleClickOnNav("items") }} active={tabSelected === "items"} >Materiais e Serviços</NavLink>
                        </NavItem>
                        <NavItem>
                          <NavLink onClick={() => { this.handleClickOnNav("log") }} active={tabSelected === "log"} >Histórico</NavLink>
                        </NavItem>
                      </Nav>
                      <TabContent activeTab={this.state.tabSelected} style={{ width: "100%" }}>
                        <TabPane tabId="info" style={{ width: "100%" }}>
                          <div className="asset-info-container">
                            <h1 className="asset-info-title">Dados do Contrato</h1>
                            <div className="asset-info-content">
                              <Row>
                                <Col md="6">
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Objeto</div>
                                    <div className="asset-info-content-data">Manutenção do Sistema Elétrico do Senado</div>
                                  </div>
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Contrato nº</div>
                                    <div className="asset-info-content-data">110/2019</div>
                                  </div>
                                </Col>
                                <Col md="6">
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Fiscal</div>
                                    <div className="asset-info-content-data">Coemant</div>
                                  </div>
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Empresa</div>
                                    <div className="asset-info-content-data">RCS Tecnologia LTDA</div>
                                  </div>
                                </Col>
                              </Row>
                              <div className="asset-info-single-container">
                                <div className="desc-sub">Descrição</div>
                                <div className="asset-info-content-data">Contratação de empresa especializada para a prestação de serviços continuados e sob demanda, referentes à operação e manutenção preventiva e corretiva do Sistema Elétrico do Complexo Arquitetônico do SENADO FEDERAL, com operação de sistema informatizado de gerenciamento de manutenção e suprimento de insumos necessários à execução dos serviços, durante o período de 36 (trinta e seis) meses consecutivos.</div>
                              </div>
                            </div>
                            <h1 className="asset-info-title">Prazos e Datas</h1>
                            <div className="asset-info-content">
                              <Row>
                                <Col md="6">
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Início da Vigência</div>
                                    <div className="asset-info-content-data">10/10/2018</div>
                                  </div>
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Final da Vigência</div>
                                    <div className="asset-info-content-data">10/10/2021</div>
                                  </div>
                                </Col>
                                <Col md="6">
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Data da Assinatura</div>
                                    <div className="asset-info-content-data">10/10/2018</div>
                                  </div>
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Data da Publicação</div>
                                    <div className="asset-info-content-data">
                                      10/10/2018
                                    </div>
                                  </div>
                                </Col>
                              </Row>
                            </div>
                          </div>
                        </TabPane>
                        <TabPane tabId="documents" style={{ width: "100%" }}>
                          <div className="asset-info-container">
                            <h1 className="asset-info-title">Documento digitalizados</h1>
                            <div className="asset-info-content">
                              <Row>
                                <Col md="6">
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Link para Contrato</div>
                                    <div className="asset-info-content-data">CT 110/2019 - Elétrica.pdf</div>
                                  </div>
                                </Col>
                              </Row>
                            </div>
                          </div>
                        </TabPane>
                        <TabPane tabId="items" style={{ width: "100%" }}>
                          <div className="asset-info-container">
                            <h1 className="asset-info-title">Materiais e Serviços</h1>
                            <div className="asset-info-content">
                              <Row>
                                <Col md="6">
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Materiais</div>
                                    <div className="asset-info-content-data">R$ 10.000,00</div>
                                  </div>
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Materiais Usados</div>
                                    <div className="asset-info-content-data">R$ 4.000,00</div>
                                  </div>
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Materiais Disponíveis</div>
                                    <div className="asset-info-content-data">R$ 6.000,00</div>
                                  </div>
                                </Col>
                                <Col md="6">
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Serviços</div>
                                    <div className="asset-info-content-data">R$ 10.000,00</div>
                                  </div>
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Serviços Usados</div>
                                    <div className="asset-info-content-data">R$ 4.000,00</div>
                                  </div>
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Serviços Disponíveis</div>
                                    <div className="asset-info-content-data">R$ 6.000,00</div>
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

export default ContractView;
