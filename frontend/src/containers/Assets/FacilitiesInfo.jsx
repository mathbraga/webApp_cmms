import React, { Component } from 'react';
import AssetCard from "../../components/Cards/AssetCard";
import getAsset from "../../utils/assets/getAsset";
import { Row, Col, Button, Badge, Nav, NavItem, NavLink, TabContent, TabPane, CustomInput } from "reactstrap";
import TableWithPages from "../../components/Tables/TableWithPages";
import "./AssetInfo.css";
import "./FacilitiesInfo.css";
import fetchDB from "../../utils/fetch/fetchDB";
import { connect } from "react-redux";
import { compose } from 'redux';
import { tableConfig } from "../Maintenance/WorkOrdersTableConfig";
import { withRouter } from "react-router";

import { Query } from 'react-apollo';
import gql from 'graphql-tag';

import { equipmentItems, equipmentConfig } from "./AssetsFakeData";

const descriptionImage = require("../../assets/img/test/facilities_picture.jpg");
const mapIcon = require("../../assets/icons/map.png");

const ENTRIES_PER_PAGE = 15;

class FacilitiesInfo extends Component {
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

    const { pageCurrent, goToPage, searchTerm } = this.state;
    const { tabSelected } = this.state;

    const assetsInfo = this.props.data;

    const pageLength = assetsInfo.assetByAssetId.orderAssetsByAssetId.edges.length;
    const edges = assetsInfo.assetByAssetId.orderAssetsByAssetId.edges;

    const pagesTotal = Math.floor(pageLength / ENTRIES_PER_PAGE) + 1;
    const showItems = edges.slice((pageCurrent - 1) * ENTRIES_PER_PAGE, pageCurrent * ENTRIES_PER_PAGE);

    const departments = assetsInfo.assetByAssetId.assetDepartmentsByAssetId.edges;
    console.log("Departments: ", departments);

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

    console.log("AssetsInfo: ", assetsInfo);
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
                    <span>{departments.map(item => (item.node.departmentByDepartmentId.departmentId)).join(' / ')}</span>
                  </Col>
                </Row>
              </div>
              <div>
                <Row>
                  <Col md="3" style={{ display: "flex", alignItems: "center", justifyContent: "flex-end" }}><span className="desc-sub">Área</span></Col>
                  <Col md="9" style={{ display: "flex", alignItems: "center" }}><span>{assetsInfo.assetByAssetId.area}</span></Col>
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
