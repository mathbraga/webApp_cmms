import React, { Component } from 'react';
import AssetCard from "../../components/Cards/AssetCard";
import { Row, Col, Button, Badge, Nav, NavItem, NavLink, TabContent, TabPane } from "reactstrap";
import "./AssetInfo.css";

const descriptionImage = require("../../assets/img/test/ar_cond.jpg");

class AssetInfo extends Component {
  render() {
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
                <NavLink href="#" active>Informações Gerais</NavLink>
              </NavItem>
              <NavItem>
                <NavLink href="#" active>Localização</NavLink>
              </NavItem>
              <NavItem>
                <NavLink href="#" active>Manutenção</NavLink>
              </NavItem>
              <NavItem>
                <NavLink href="#" active>Garantia</NavLink>
              </NavItem>
              <NavItem>
                <NavLink href="#" active>Ativos</NavLink>
              </NavItem>
              <NavItem>
                <NavLink href="#" active>Arquivos</NavLink>
              </NavItem>
              <NavItem>
                <NavLink href="#" active>Histórico</NavLink>
              </NavItem>
            </Nav>
            <TabContent style={{ width: "100%" }}>
              <TabPane style={{ width: "100%" }}>
                Hey
              </TabPane>
            </TabContent>
          </div>
        </Row>
      </AssetCard>
    );
  }
}

export default AssetInfo;