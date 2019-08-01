import React, { Component } from 'react';
import AssetCard from "../../components/Cards/AssetCard";
import { Row, Col, Button, Badge, Nav, NavItem, NavLink, TabContent, TabPane, CustomInput } from "reactstrap";
import TableWithPages from "../../components/Tables/TableWithPages";
import "./AssetInfo.css";

import { equipmentItems, equipmentConfig } from "./AssetsFakeData";

const descriptionImage = require("../../assets/img/test/ar_cond.jpg");
const mapIcon = require("../../assets/icons/map.png");


const thead =
  <tr>
    <th className="text-center checkbox-cell">
      <CustomInput type="checkbox" />
    </th>
    {equipmentConfig.map(column => (
      <th style={column.style} className={column.className}>{column.description}</th>))
    }
  </tr>

const tbody = equipmentItems.map(item => (
  <tr>
    <td className="text-center checkbox-cell"><CustomInput type="checkbox" /></td>
    <td>
      <div>{item.equipment}</div>
      <div className="small text-muted">{item.id}</div>
    </td>
    <td>
      <div className="text-center">{item.manufacturer}</div>
    </td>
    <td>
      <div className="text-center">{item.model}</div>
    </td>
    <td>
      <div className="text-center">{item.category}</div>
    </td>
    <td>
      <div className="text-center">
        <img src={mapIcon} alt="Google Maps" style={{ width: "35px", height: "35px" }} />
      </div>
    </td>
  </tr>))

class AssetInfo extends Component {
  constructor(props) {
    super(props);
    this.state = {
      tabSelected: "info",
    };
  }

  handleClickOnNav(tabSelected) {
    this.setState({ tabSelected });
  }

  render() {
    const { tabSelected } = this.state;
    return (
      <AssetCard
        sectionName={'Equipamento'}
        sectionDescription={'Ficha descritiva'}
        handleCardButton={() => { }}
        buttonName={'Nova OS'}
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
                <Col md="9" style={{ display: "flex", alignItems: "center" }}><span>Carrier Corporation LTDA</span></Col>
              </Row>
            </div>
            <div>
              <Row>
                <Col md="3" style={{ display: "flex", alignItems: "center", justifyContent: "flex-end" }}><span className="desc-sub">Código</span></Col>
                <Col md="9" style={{ display: "flex", alignItems: "center" }}><span>ESX234DF</span></Col>
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
                    <TableWithPages thead={thead} tbody={tbody} />
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
    );
  }
}

export default AssetInfo;