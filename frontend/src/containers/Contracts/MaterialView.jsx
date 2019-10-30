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
                                    <div className="asset-info-content-data">Luminária 2x14 W de embutir</div>
                                  </div>
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Categoria</div>
                                    <div className="asset-info-content-data">Elétrica</div>
                                  </div>
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Subcategoria</div>
                                    <div className="asset-info-content-data">Iluminação</div>
                                  </div>
                                </Col>
                                <Col md="6">
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Código</div>
                                    <div className="asset-info-content-data">SF-00274</div>
                                  </div>
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Versão</div>
                                    <div className="asset-info-content-data">v02</div>
                                  </div>
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">CATSER</div>
                                    <div className="asset-info-content-data">1538</div>
                                  </div>
                                </Col>
                              </Row>
                              <div className="asset-info-single-container">
                                <div className="desc-sub">Descrição Detalhada</div>
                                <div className="asset-info-content-data">Fornecimento e instalação de luminária de embutir completa T5 2 x 14W, com reator e lâmpada.</div>
                              </div>
                            </div>
                            <h1 className="asset-info-title">Definição dos Serviços e Materiais</h1>
                            <div className="asset-info-content">
                              <div className="asset-info-single-container">
                                <div className="desc-sub">Detalhamento dos Materiais</div>
                                <div className="asset-info-content-data">
                                  Luminária de embutir completa 2 x 14W com as seguintes características mínimas:
                                  <ul>
                                    <li>
                                      Dimensões aproximadas: 620 x 270 mm e perfil baixo (menor que 45 mm) para instalação em forro estreito;
                                    </li>
                                    <li>
                                      Corpo em chapa de aço, completamente fechada, pintura eletroestática em tinta epóxi a pó, na cor branca;
                                    </li>
                                    <li>
                                      Refletor parabólico em alumínio anodizado com pureza acima de 95%;
                                    </li>
                                    <li>
                                      Aletas parabólicas em alumínio anodizado com pureza acima de 95%;
                                    </li>
                                    <li>
                                      Alojamento do reator na parte inferior, com tampa removível, para fácil manutenção (sistema de encaixe de pressão, por bilhas ou molas), acesso a reator e lâmpadas manualmente, sem auxílio de ferramentas;
                                    </li>
                                    <li>
                                      Rendimento acima de 75%;
                                    </li>
                                    <li>
                                      Soquetes de engate rápido, com travamento antivibratório;
                                    </li>
                                    <li>
                                      Esteticamente compatível com o existente no Senado Federal.
                                    </li>
                                  </ul>
                                  Com 02 (duas) lâmpadas fluorescente T5 de 14 W com as seguintes características mínimas:
                                  <ul>
                                    <li>
                                      Temperatura de cor mínima de 4000K;
                                    </li>
                                    <li>
                                      Tensão nominal de 220 V;
                                    </li>
                                    <li>
                                      Base G5;
                                    </li>
                                    <li>
                                      Fluxo luminoso mínimo de 1200 lm;
                                    </li>
                                    <li>
                                      Índice de Reprodução de Cor mínimo de 80;
                                    </li>
                                    <li>
                                      Eficiência luminosa a 35°C de pelo menos 96 lumens/Watt;
                                    </li>
                                    <li>
                                      Vida mediana mínima de 20000 horas;
                                    </li>
                                    <li>
                                      Com as seguintes marcações legíveis no bulbo ou na base: potência nominal (W), designação da cor, nome do fabricante ou marca registrada e modelo.
                                    </li>
                                  </ul>
                                  Reator eletrônico com as seguintes características mínimas:
                                  <ul>
                                    <li>
                                      Para duas lâmpadas fluorescentes tubulares 14 W;
                                    </li>
                                    <li>
                                      Partida instantânea;
                                    </li>
                                    <li>
                                      Com selo do INMETRO;
                                    </li>
                                    <li>
                                      Com selo do Procel;
                                    </li>
                                    <li>
                                      Distorção harmônica total (THDi) inferior a 10%;
                                    </li>
                                    <li>
                                      Alto fator de potência (superior a 0,97);
                                    </li>
                                    <li>
                                      Alimentação de 220 V;
                                    </li>
                                  </ul>
                                  Cabo de cobre multipolar isolado 0,6/1 kV 3x2,5mm² resistente a chama, livre de halogênios, com as seguintes características mínimas:
                                  <ul>
                                    <li>
                                      Área nominal de cada seção condutora: 2,5 mm²;
                                    </li>
                                    <li>
                                      Cabo flexível tripolar de cobre (têmpera mole) formado por fios de cobre nu (não revestido);
                                    </li>
                                    <li>
                                      Veias internas nas cores preto, azul e verde;
                                    </li>
                                    <li>
                                      Isolação em dupla camada por composto termofixo poliolefínico extrudado não halogenado EPR/B;
                                    </li>
                                    <li>
                                      Cobertura por composto termoplástico com base poliolefínica não halogenada;
                                    </li>
                                    <li>
                                      Tensão mínima de isolação (Vo/V): 0,6/1kV;
                                    </li>
                                    <li>
                                      Temperatura de operação (classe térmica) em serviço contínuo (regime permanente): 90ºC;
                                    </li>
                                    <li>
                                      Encordoamento extraflexível: classe 5 (ABNT NBR NM 280:2011 - Condutores de Cabos Isolados (IEC 60228, MOD));
                                    </li>
                                    <li>
                                      Característica de não propagação e com autoextinção de chama, livre de halogênio, baixa emissão de fumaça e gases tóxicos, ausência de emissão de gases corrosivos;
                                    </li>
                                    <li>
                                      Atendimento às exigências das normas ABNT ABNT NBR 13248 - Cabos de potência e controle e condutores isolados sem cobertura, com isolação extrudada e com baixa emissão de fumaça para tensões até 1 kVRequisitos de desempenho, NBR 13570 e ABNT NBR NM 280:2011 - Condutores de Cabos Isolados (IEC 60228, MOD);
                                    </li>
                                    <li>
                                      Marcação indelével no cabo, em intervalos regulares de até 50 cm, contendo o nome do fabricante, a seção nominal do condutor (em milímetros quadrados), a tensão de isolamento (fase-fase) e o número da norma ABNT NBR 13248 - Cabos de potência e controle e condutores isolados sem cobertura, com isolação extrudada e com baixa emissão de fumaça para tensões até 1 kVRequisitos de desempenho;
                                    </li>
                                    <li>
                                      Com certificado do INMETRO.
                                    </li>
                                    <li>
                                      Plugue (macho) com 3 pólos (2P+T), com as seguintes características mínimas:
                                    </li>
                                    <li>
                                      Para 10A e 250V
                                    </li>
                                    <li>
                                      Posição 180 graus (axial)
                                    </li>
                                    <li>
                                      De acordo com a norma NBR 14136
                                    </li>
                                    <li>
                                      Com prensa-cabos.
                                    </li>
                                    <li>
                                      Prolongador (plugue fêmea) com 3 pólos (2P+T), com as seguintes características mínimas:
                                    </li>
                                    <li>
                                      Para 10A e 250V
                                    </li>
                                    <li>
                                      Posição 180 graus (axial)
                                    </li>
                                    <li>
                                      De acordo com a norma NBR 14136
                                    </li>
                                    <li>
                                      Com prensa-cabos.
                                    </li>
                                  </ul>
                                </div>
                              </div>
                              <div className="asset-info-single-container">
                                <div className="desc-sub">Detalhamento dos Serviços</div>
                                <div className="asset-info-content-data">
                                  <ul>
                                    <li>
                                      O fornecimento das luminárias deverá ser completo, ou seja, deverá contemplar todos os acessórios para a instalação, tais como reatores, lâmpadas, elementos de fixação (tirantes, suportes, suporte “pé de galinha”, entre outros).
                                    </li>
                                    <li>
                                      Deverão ser previstas bordas e acessórios para fixação em forros especiais.
                                    </li>
                                    <li>
                                      Para alimentação elétrica, as luminárias deverão possuir cabos 3x2,5 mm2 com plugue macho e fêmea 2P+T (três pinos) de 10A.
                                    </li>
                                    <li>
                                      O item contempla a montagem da luminária, incluindo as fixações internas de elementos como lâmpada e reatores, a fixação da luminária no forro, as conexões elétricas internas e externas (incluindo a conexão de aterramento da carcaça na luminária e no reator) e o teste de funcionamento.
                                    </li>
                                    <li>
                                      Deverá ser feita a limpeza das luminárias e lâmpadas ao final dos serviços.
                                   </li>
                                  </ul>
                                </div>
                              </div>
                            </div>
                          </div>
                        </TabPane>
                        <TabPane tabId="contracts" style={{ width: "100%" }}>
                          <div className="asset-info-container">
                            <h1 className="asset-info-title">Saldo Total</h1>
                            <div className="asset-info-content">
                              <Row>
                                <Col md="6">
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Contratações Vigentes</div>
                                    <div className="asset-info-content-data">155 unidades</div>
                                  </div>
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Saldo Disponível</div>
                                    <div className="asset-info-content-data">134 unidades</div>
                                  </div>
                                </Col>
                                <Col md="6">
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Valor Contratado</div>
                                    <div className="asset-info-content-data">R$ 12.000,00</div>
                                  </div>
                                  <div className="asset-info-single-container">
                                    <div className="desc-sub">Valor Disponível</div>
                                    <div className="asset-info-content-data">R$ 9.000,00</div>
                                  </div>
                                </Col>
                              </Row>
                            </div>
                            <h1 className="asset-info-title">Saldo por Contrato</h1>
                            <div className="asset-info-content">
                              <ol style={{ padding: "0", listStyle: "none" }}>
                                <li style={{ marginTop: "15px", border: "1px solid #d2d2d2", padding: "20px" }}>
                                  <span style={{ fontWeight: "400", fontSize: "18px" }}>Contrato nº 119/2019 - Manutenção Elétrica</span>
                                  <Row style={{ paddingLeft: "30px" }}>
                                    <Col md="6">
                                      <div className="asset-info-single-container">
                                        <div className="desc-sub">Quantidade Contratada</div>
                                        <div className="asset-info-content-data">50 unidades</div>
                                      </div>
                                      <div className="asset-info-single-container">
                                        <div className="desc-sub">Quantidade Disponível</div>
                                        <div className="asset-info-content-data">34 unidades</div>
                                      </div>
                                    </Col>
                                    <Col md="6">
                                      <div className="asset-info-single-container">
                                        <div className="desc-sub">Valor Unitário do Contrato</div>
                                        <div className="asset-info-content-data">R$ 2,00</div>
                                      </div>
                                      <div className="asset-info-single-container">
                                        <div className="desc-sub">Valor Unitário da Pesquisa</div>
                                        <div className="asset-info-content-data">R$ 3,00</div>
                                      </div>
                                    </Col>
                                  </Row>
                                </li>
                                <li style={{ marginTop: "30px", border: "1px solid #d2d2d2", padding: "20px" }}>
                                  <span style={{ fontWeight: "400", fontSize: "18px" }}>
                                    Contrato nº 012/2017 - Aquisição de insumos
                                  </span>
                                  <Row style={{ paddingLeft: "30px" }}>
                                    <Col md="6">
                                      <div className="asset-info-single-container">
                                        <div className="desc-sub">Quantidade Contratada</div>
                                        <div className="asset-info-content-data">50 unidades</div>
                                      </div>
                                      <div className="asset-info-single-container">
                                        <div className="desc-sub">Quantidade Disponível</div>
                                        <div className="asset-info-content-data">34 unidades</div>
                                      </div>
                                    </Col>
                                    <Col md="6">
                                      <div className="asset-info-single-container">
                                        <div className="desc-sub">Valor Unitário do Contrato</div>
                                        <div className="asset-info-content-data">R$ 2,00</div>
                                      </div>
                                      <div className="asset-info-single-container">
                                        <div className="desc-sub">Valor Unitário da Pesquisa</div>
                                        <div className="asset-info-content-data">R$ 3,00</div>
                                      </div>
                                    </Col>
                                  </Row>
                                </li>
                                <li style={{ marginTop: "30px", border: "1px solid #d2d2d2", padding: "20px" }}>
                                  <span style={{ fontWeight: "400", fontSize: "18px" }}>
                                    Contrato nº 077/2018 - Reforma de gabinetes
                                  </span>
                                  <Row style={{ paddingLeft: "30px" }}>
                                    <Col md="6">
                                      <div className="asset-info-single-container">
                                        <div className="desc-sub">Quantidade Contratada</div>
                                        <div className="asset-info-content-data">50 unidades</div>
                                      </div>
                                      <div className="asset-info-single-container">
                                        <div className="desc-sub">Quantidade Disponível</div>
                                        <div className="asset-info-content-data">34 unidades</div>
                                      </div>
                                    </Col>
                                    <Col md="6">
                                      <div className="asset-info-single-container">
                                        <div className="desc-sub">Valor Unitário do Contrato</div>
                                        <div className="asset-info-content-data">R$ 2,00</div>
                                      </div>
                                      <div className="asset-info-single-container">
                                        <div className="desc-sub">Valor Unitário da Pesquisa</div>
                                        <div className="asset-info-content-data">R$ 3,00</div>
                                      </div>
                                    </Col>
                                  </Row>
                                </li>
                              </ol>
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
