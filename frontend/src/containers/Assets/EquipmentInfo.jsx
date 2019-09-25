import React, { Component } from 'react';
import AssetCard from "../../components/Cards/AssetCard";
import getAsset from "../../utils/assets/getAsset";
import { Row, Col, Button, Badge, Nav, NavItem, NavLink, TabContent, TabPane, CustomInput } from "reactstrap";
import TableWithPages from "../../components/Tables/TableWithPages";
import "./AssetInfo.css";
import fetchDB from "../../utils/fetch/fetchDB";
import { connect } from "react-redux";
import { tableConfig } from "../Maintenance/WorkOrdersTableConfig";

import { Query } from 'react-apollo';
import gql from 'graphql-tag';

import { equipmentItems, equipmentConfig } from "./AssetsFakeData";

const descriptionImage = require("../../assets/img/test/equipment_picture.jpg");
const mapIcon = require("../../assets/icons/map.png");

const ENTRIES_PER_PAGE = 15;

class AssetInfo extends Component {
  constructor(props) {
    super(props);
    this.state = {
      tabSelected: "info",
      location: false,
      pageCurrent: 1,
      goToPage: 1
    };
    this.handleClickOnNav = this.handleClickOnNav.bind(this);
    this.setGoToPage = this.setGoToPage.bind(this);
    this.setCurrentPage = this.setCurrentPage.bind(this);
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

  render() {
    const assetId = this.props.location.pathname.slice(13);

    const assetInfoQuery = gql`
      query ($assetId: String!){
        assetByAssetId(assetId: $assetId) {
          category
          assetId
          model
          orderAssetsByAssetId(condition: {assetId: $assetId}, orderBy: ASSET_ID_ASC) {
            edges {
              node {
                assetId
                orderId
                orderByOrderId {
                  orderId
                  requestText
                  status
                  requestPerson
                  createdAt
                  dateLimit
                }
              }
            }
          }
        }
      }`;

    const { pageCurrent, goToPage, searchTerm } = this.state;
    const { tabSelected } = this.state;

    return (
      <Query
        query={assetInfoQuery}
        variables={{ assetId: assetId }}
      >{
          ({ loading, error, data }) => {
            if (loading) return null
            if (error) {
              console.log("Erro ao tentar baixar os ativos!");
              return null
            }
            const assetsInfo = data;

            const pageLength = assetsInfo.assetByAssetId.orderAssetsByAssetId.edges.length;
            const edges = assetsInfo.assetByAssetId.orderAssetsByAssetId.edges;

            const pagesTotal = Math.floor(pageLength / ENTRIES_PER_PAGE) + 1;
            const showItems = edges.slice((pageCurrent - 1) * ENTRIES_PER_PAGE, pageCurrent * ENTRIES_PER_PAGE);

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
                  <div>{item.node.orderId}</div>
                </td>
                <td>
                  <div className="text-center">{item.node.orderByOrderId.requestText}</div>
                </td>
                <td>
                  <div className="text-center">{item.node.orderByOrderId.status}</div>
                </td>
                <td>
                  <div className="text-center">{item.node.orderByOrderId.createdAt}</div>
                </td>
                <td>
                  <div className="text-center">{item.node.orderByOrderId.dateLimit}</div>
                </td>
                <td>
                  <div className="text-center">{item.node.orderByOrderId.requestPerson}</div>
                </td>
              </tr>))
            return (
              <AssetCard
                sectionName={assetsInfo.assetByAssetId.category === 'A' ? 'Equipamento' : 'Edifício'}
                sectionDescription={'Ficha descritiva'}
                handleCardButton={() => assetsInfo.assetByAssetId.category === 'A' ?
                  this.props.history.push('/ativos/equipamentos') : this.props.history.push('/ativos/edificios')}
                buttonName={assetsInfo.assetByAssetId.category === 'A' ? 'Equipamentos' : 'Edifícios'}
              >
                <Row>
                  <Col md="2">
                    <div className="desc-box">
                      <img className="desc-image" src={descriptionImage} alt="Ar-condicionado" />
                      <div className="desc-status">
                        <Badge className="mr-1 desc-badge" color="success" >Funcionando</Badge>
                      </div>
                    </div>
                  </Col>
                  <Col className="flex-column" md="10">
                    <div style={{ flexGrow: "1" }}>
                      <Row>
                        <Col md="3" style={{ textAlign: "end" }}><span className="desc-name">Ar-condicionado</span></Col>
                        <Col md="9" style={{ textAlign: "justify" }}><span>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean non aliquet ante. Nunc consectetur nulla id diam sodales sagittis vel sed ligula. Praesent ullamcorper turpis nibh, eu varius magna efficitur eu. Duis euismod faucibus mi, quis fermentum est aliquet nec.</span></Col>
                      </Row>
                    </div>
                    <div>
                      <Row>
                        <Col md="3" style={{ display: "flex", alignItems: "center", justifyContent: "flex-end" }}><span className="desc-sub">Categoria</span></Col>
                        <Col md="9" style={{ display: "flex", alignItems: "center" }}><span>Máquinas eletromecânicas</span></Col>
                      </Row>
                    </div>
                    <div>
                      <Row>
                        <Col md="3" style={{ display: "flex", alignItems: "center", justifyContent: "flex-end" }}><span className="desc-sub">Fabricante</span></Col>
                        <Col md="9" style={{ display: "flex", alignItems: "center" }}><span>{assetsInfo.assetByAssetId.model}</span></Col>
                      </Row>
                    </div>
                    <div>
                      <Row>
                        <Col md="3" style={{ display: "flex", alignItems: "center", justifyContent: "flex-end" }}><span className="desc-sub">Código</span></Col>
                        <Col md="9" style={{ display: "flex", alignItems: "center" }}><span>{assetsInfo.assetByAssetId.assetId}</span></Col>
                      </Row>
                    </div>
                  </Col>
                </Row>
                <Row>
                  <div style={{ margin: "20px", width: "100%" }}>
                    <Nav tabs>
                      <NavItem>
                        <NavLink onClick={() => { this.handleClickOnNav("info") }} active={tabSelected === "info"} >Informações Gerais</NavLink>
                      </NavItem>
                      <NavItem>
                        <NavLink onClick={() => { this.handleClickOnNav("location") }} active={tabSelected === "location"} >Localização</NavLink>
                      </NavItem>
                      <NavItem>
                        <NavLink onClick={() => { this.handleClickOnNav("maintenance") }} active={tabSelected === "maintenance"} >Manutenção</NavLink>
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
                        <div>
                          Informações gerais sobre o equipamento.
                  </div>
                      </TabPane>
                      <TabPane tabId="location" style={{ width: "100%" }}>
                        <div>
                          Localização do equipamento.
                  </div>
                      </TabPane>
                      <TabPane tabId="maintenance" style={{ width: "100%" }}>
                        <Row>
                          <Col>
                            <TableWithPages
                              thead={thead}
                              tbody={tbody}
                              pagesTotal={pagesTotal}
                              pageCurrent={pageCurrent}
                              goToPage={goToPage}
                              setCurrentPage={this.setCurrentPage}
                              setGoToPage={this.setGoToPage}
                            />
                          </Col>
                        </Row>
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
            )
          }}</Query>
    );
  }
}

const mapStateToProps = storeState => {
  return {
    session: storeState.auth.session
  }
}

export default connect(mapStateToProps)(AssetInfo);