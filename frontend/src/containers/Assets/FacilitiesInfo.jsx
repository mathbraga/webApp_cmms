import React, { Component } from 'react';
import AssetCard from "../../components/Cards/AssetCard";
import getAsset from "../../utils/assets/getAsset";
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
  FormGroup,
} from "reactstrap";
import TableWithPages from "../../components/Tables/TableWithPages";
import "./AssetInfo.css";
import "./FacilitiesInfo.css";
import fetchDB from "../../utils/fetch/fetchDB";
import { connect } from "react-redux";
import { compose } from 'redux';
import { withRouter } from "react-router";
import replaceNull from '../../utils/text/replaceNull';

import { Query } from 'react-apollo';
import gql from 'graphql-tag';

import { equipmentItems, equipmentConfig } from "./AssetsFakeData";

const descriptionImage = require("../../assets/img/test/facilities_picture.jpg");
const mapIcon = require("../../assets/icons/map.png");
const searchItem = require("../../assets/icons/search_icon.png");

const ENTRIES_PER_PAGE = 15;

const tableConfig = [
  { name: "OS", style: { width: "50px" }, className: "text-center" },
  { name: "Título", style: { width: "300px" }, className: "text-justify" },
  { name: "Status", style: { width: "100px" }, className: "text-center" },
  { name: "Prioridade", style: { width: "100px" }, className: "text-center" },
  { name: "Prazo Final", style: { width: "100px" }, className: "text-center" },
];

const ORDER_STATUS_TYPE = {
  'CAN': 'Cancelada',
  'NEG': 'Negada',
  'PEN': 'Pendente',
  'SUS': 'Suspensa',
  'FIL': 'Fila de espera',
  'EXE': 'Execução',
  'CON': 'Concluída',
}

const ORDER_PRIORITY_TYPE = {
  'BAI': 'Baixa',
  'NOR': 'Normal',
  'ALT': 'Alta',
  'URG': 'Urgente',
};

class FacilitiesInfo extends Component {
  constructor(props) {
    super(props);
    this.state = {
      tabSelected: "info",
      location: false,
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

    const { pageCurrent, goToPage, searchTerm } = this.state;
    const { tabSelected } = this.state;

    const assetsInfo = this.props.data;

    const pageLength = assetsInfo.assetByAssetId.orderAssetsByAssetId.edges.length;
    const edges = assetsInfo.assetByAssetId.orderAssetsByAssetId.edges;

    const statusCounter = {
      'CAN': 0,
      'NEG': 0,
      'PEN': 0,
      'SUS': 0,
      'FIL': 0,
      'EXE': 0,
      'CON': 0,
    };
    edges.forEach(item => statusCounter[item.node.orderByOrderId.status] += 1);
    const totalOS = edges.length;

    console.log("statusCounter: ", statusCounter);

    let filteredItems = edges;
    if (searchTerm.length > 0) {
      const searchTermLower = searchTerm.toLowerCase();
      filteredItems = edges.filter(function (item) {
        return (
          // item.node.orderByOrderId.category.toLowerCase().includes(searchTermLower) ||
          item.node.orderByOrderId.requestPerson.toLowerCase().includes(searchTermLower) ||
          item.node.orderByOrderId.requestText.toLowerCase().includes(searchTermLower) ||
          item.node.orderByOrderId.status.toLowerCase().includes(searchTermLower)
        );
      });
    }

    const pagesTotal = Math.floor(pageLength / ENTRIES_PER_PAGE) + 1;
    const showItems = filteredItems.slice((pageCurrent - 1) * ENTRIES_PER_PAGE, pageCurrent * ENTRIES_PER_PAGE);

    const departments = assetsInfo.assetByAssetId.assetDepartmentsByAssetId.edges;

    console.log("Showitems: ", showItems);

    const thead =
      <tr>
        <th className="text-center checkbox-cell">
          <CustomInput type="checkbox" />
        </th>
        {tableConfig.map(column => (
          <th style={column.style} className={column.className}>{column.name}</th>))
        }
      </tr>

    const tbody = showItems.map(item => (
      <tr
        onClick={() => { this.props.history.push('/manutencao/os/view/' + item.node.orderByOrderId.orderId) }}
      >
        <td className="text-center checkbox-cell"><CustomInput type="checkbox" /></td>
        <td>
          <div className="text-center">{(item.node.orderId + "").padStart(4, "0")}</div>
        </td>
        <td>
          <div>{item.node.orderByOrderId.requestTitle}</div>
          <div className="small text-muted">{item.node.orderByOrderId.requestLocal}</div>
        </td>
        <td>
          <div className="text-center">{ORDER_STATUS_TYPE[item.node.orderByOrderId.status]}</div>
        </td>
        <td>
          <div className="text-center">{ORDER_PRIORITY_TYPE[item.node.orderByOrderId.priority]}</div>
        </td>
        <td>
          <div className="text-center">{item.node.orderByOrderId.dateLimit && item.node.orderByOrderId.dateLimit.split("T")[0]}</div>
        </td>
      </tr>))

    return (
      <div className="asset-container">
        <AssetCard
          sectionName={'Edifício / Área'}
          sectionDescription={'Ficha descritiva do imóvel'}
          handleCardButton={() => assetsInfo.assetByAssetId.category === 'A' ?
            this.props.history.push('/ativos/equipamentos') : this.props.history.push('/ativos/edificios')}
          buttonName={'Edifícios'}
        >
          <Row>
            <Col md="2" style={{ textAlign: "left" }}>
              <div className="desc-box">
                <div className="desc-img-container">
                  <img className="desc-image" src={descriptionImage} alt="Ar-condicionado" />
                </div>
                <div className="desc-status">
                  <Badge className="mr-1 desc-badge" color="success" >Trânsito Livre</Badge>
                </div>
              </div>
            </Col>
            <Col className="flex-column" md="10">
              <div style={{ flexGrow: "1" }}>
                <Row>
                  <Col md="3" style={{ textAlign: "end" }}><span className="desc-name">Edifício / Área</span></Col>
                  <Col md="9" style={{ textAlign: "justify", paddingTop: "5px" }}><span>{assetsInfo.assetByAssetId.name}</span></Col>
                </Row>
              </div>
              <div>
                <Row>
                  <Col md="3" style={{ display: "flex", alignItems: "center", justifyContent: "flex-end" }}><span className="desc-sub">Código</span></Col>
                  <Col md="9" style={{ display: "flex", alignItems: "center" }}><span>{assetsInfo.assetByAssetId.assetId}</span></Col>
                </Row>
              </div>
              <div>
                <Row>
                  <Col md="3" style={{ display: "flex", alignItems: "center", justifyContent: "flex-end" }}><span className="desc-sub">Departamento(s)</span></Col>
                  <Col md="9" style={{ display: "flex", alignItems: "center" }}>
                    <span>{departments.map(item => (item.node.departmentByDepartmentId.departmentId)).join(' / ') || "Não cadastrado"}</span>
                  </Col>
                </Row>
              </div>
              <div>
                <Row>
                  <Col md="3" style={{ display: "flex", alignItems: "center", justifyContent: "flex-end" }}><span className="desc-sub">Área</span></Col>
                  <Col md="9" style={{ display: "flex", alignItems: "center" }}><span>{assetsInfo.assetByAssetId.area + " m²"}</span></Col>
                </Row>
              </div>
            </Col>
          </Row>
          <Row>
            <div style={{ margin: "40px 20px 20px 20px", width: "96%" }}>
              <Nav tabs>
                <NavItem>
                  <NavLink onClick={() => { this.handleClickOnNav("info") }} active={tabSelected === "info"} >Informações Gerais</NavLink>
                </NavItem>
                <NavItem>
                  <NavLink onClick={() => { this.handleClickOnNav("location") }} active={tabSelected === "location"} >Planta Arquitetônica</NavLink>
                </NavItem>
                <NavItem>
                  <NavLink onClick={() => { this.handleClickOnNav("maintenance") }} active={tabSelected === "maintenance"} >Manutenções</NavLink>
                </NavItem>
                <NavItem>
                  <NavLink onClick={() => { this.handleClickOnNav("warranty") }} active={tabSelected === "warranty"} >Garantia</NavLink>
                </NavItem>
                <NavItem>
                  <NavLink onClick={() => { this.handleClickOnNav("asset") }} active={tabSelected === "asset"} >Ativos</NavLink>
                </NavItem>
                <NavItem>
                  <NavLink onClick={() => { this.handleClickOnNav("file") }} active={tabSelected === "file"} >Arquivos</NavLink>
                </NavItem>
                <NavItem>
                  <NavLink onClick={() => { this.handleClickOnNav("log") }} active={tabSelected === "log"} >Histórico</NavLink>
                </NavItem>
              </Nav>
              <TabContent activeTab={this.state.tabSelected} style={{ width: "100%" }}>
                <TabPane tabId="info" style={{ width: "100%" }}>
                  <div className="asset-info-container">
                    <h1 className="asset-info-title">Dados Gerais</h1>
                    <div className="asset-info-content">
                      <Row>
                        <Col md="6">
                          <div className="asset-info-single-container">
                            <div className="desc-sub">Nome do Edifício ou Área</div>
                            <div className="asset-info-content-data">{assetsInfo.assetByAssetId.name}</div>
                          </div>
                          <div className="asset-info-single-container">
                            <div className="desc-sub">Código</div>
                            <div className="asset-info-content-data">{assetsInfo.assetByAssetId.assetId}</div>
                          </div>
                        </Col>
                        <Col md="6">
                          <div className="asset-info-single-container">
                            <div className="desc-sub">Departamento (s)</div>
                            <div className="asset-info-content-data">{departments.map(item => (item.node.departmentByDepartmentId.departmentId)).join(' / ') || "Não cadastrado"}</div>
                          </div>
                        </Col>
                      </Row>
                      <div className="asset-info-single-container">
                        <div className="desc-sub">Descrição do Edifício</div>
                        <div className="asset-info-content-data">{assetsInfo.assetByAssetId.description}</div>
                      </div>
                    </div>
                    <h1 className="asset-info-title">Localização</h1>
                    <div className="asset-info-content">
                      <Row>
                        <Col md="6">
                          <div className="asset-info-single-container">
                            <div className="desc-sub">Ativo Pai</div>
                            <div className="asset-info-content-data">{assetsInfo.assetByAssetId.assetByParent.assetId + " / " + assetsInfo.assetByAssetId.assetByParent.name}</div>
                          </div>
                          <div className="asset-info-single-container">
                            <div className="desc-sub">Área</div>
                            <div className="asset-info-content-data">{Math.trunc(assetsInfo.assetByAssetId.area) + " m²"}</div>
                          </div>
                        </Col>
                        <Col md="6">
                          <div className="asset-info-single-container">
                            <div className="desc-sub">Latidude do Local</div>
                            <div className="asset-info-content-data">{assetsInfo.assetByAssetId.latitude}</div>
                          </div>
                          <div className="asset-info-single-container">
                            <div className="desc-sub">Longitude do Local</div>
                            <div className="asset-info-content-data">{assetsInfo.assetByAssetId.longitude}</div>
                          </div>
                        </Col>
                      </Row>
                    </div>
                  </div>
                </TabPane>
                <TabPane tabId="location" style={{ width: "100%" }}>
                  <div className="asset-info-container">
                    <h1 className="asset-info-title">Planta Arquitetônica</h1>
                    <div className="asset-info-content">
                      <div className="asset-info-map"></div>
                    </div>
                  </div>
                </TabPane>
                <TabPane tabId="maintenance" style={{ width: "100%" }}>
                  <div className="asset-info-container">
                    <h1 className="asset-info-title">Relatório de Manutenções</h1>
                    <div className="asset-info-content">
                      <Row>
                        <Col md="6">
                          <div className="asset-info-single-container">
                            <div className="desc-sub">Manutenções Pendentes</div>
                            <div className="asset-info-content-data">
                              {((statusCounter['FIL'] + statusCounter['PEN'] + statusCounter['SUS']) + "").padStart(4, "0")}
                            </div>
                          </div>
                          <div className="asset-info-single-container">
                            <div className="desc-sub">Manutenções Totais</div>
                            <div className="asset-info-content-data">{(totalOS + "").padStart(4, "0")}</div>
                          </div>
                        </Col>
                        <Col md="6">
                          <div className="asset-info-single-container">
                            <div className="desc-sub">Preventivas Agendadas</div>
                            <div className="asset-info-content-data">OS-0021 / OS-0025</div>
                          </div>
                          <div className="asset-info-single-container">
                            <div className="desc-sub">Requisições para Análise</div>
                            <div className="asset-info-content-data">RQ-0011 / RQ-0015</div>
                          </div>
                        </Col>
                      </Row>
                    </div>
                    <h1 className="asset-info-title">Tabela de Manutenções</h1>
                    <div className="asset-info-content">
                      <Row>
                        <Col md="6">
                          <div className="asset-info-single-container">
                            <div className="desc-sub">Ativos Filhos Incluídos</div>
                            <div className="asset-info-content-data">Não</div>
                          </div>
                        </Col>
                        <Col md="6" style={{ display: "flex", alignItems: "flex-end" }}>
                          <FormGroup style={{ margin: "0" }}>
                            <CustomInput type="switch" id="child-assets" name="customSwitch" label="Incluir ativos filhos" />
                          </FormGroup>
                        </Col>
                      </Row>
                      <div className="asset-info-table-search">
                        <form>
                          <InputGroup>
                            <Input placeholder="Pesquisar ..." value={searchTerm} onChange={this.handleChangeSearchTerm} />
                            <InputGroupAddon addonType="append">
                              <InputGroupText><img src={searchItem} alt="" style={{ width: "19px", height: "16px", margin: "3px 0px" }} /></InputGroupText>
                            </InputGroupAddon>
                          </InputGroup>
                        </form>
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
                  <div className="asset-info-container">
                    <h1 className="asset-info-title">Dados da Garantia</h1>
                    <div className="asset-info-content">
                      <Row>
                        <Col md="6">
                          <div className="asset-info-single-container">
                            <div className="desc-sub">Fornecedor</div>
                            <div className="asset-info-content-data">Over Elevadores Ltda</div>
                          </div>
                          <div className="asset-info-single-container">
                            <div className="desc-sub">Telefone</div>
                            <div className="asset-info-content-data">(61) 3256-4562</div>
                          </div>
                        </Col>
                        <Col md="6">
                          <div className="asset-info-single-container">
                            <div className="desc-sub">Data Inicial</div>
                            <div className="asset-info-content-data">01/01/2019</div>
                          </div>
                          <div className="asset-info-single-container">
                            <div className="desc-sub">Data Final</div>
                            <div className="asset-info-content-data">01/01/2022</div>
                          </div>
                        </Col>
                      </Row>
                    </div>
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
    );
  }
}

const mapStateToProps = storeState => {
  return {
    session: storeState.auth.session
  }
}

export default compose(
  withRouter,
  connect(mapStateToProps),
)(FacilitiesInfo);
