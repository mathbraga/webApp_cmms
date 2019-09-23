import React, { Component } from "react";
import getWorkOrder from "../../utils/maintenance/getWorkOrder";
import AssetCard from "../../components/Cards/AssetCard";
import { Row, Col, Button, Badge, Nav, NavItem, NavLink, TabContent, TabPane, CustomInput } from "reactstrap";

import { Query } from 'react-apollo';
import gql from 'graphql-tag';

const descriptionImage = require("../../assets/img/test/ar_cond.jpg");

class WorkOrderView extends Component {
  constructor(props){
    super(props);
    this.state = {
      tabSelected: "info",
    }
    this.handleClickOnNav = this.handleClickOnNav.bind(this);
  }

  handleClickOnNav(tabSelected) {
    this.setState({ tabSelected: tabSelected });
  }
  
  render() {
    const orderId = Number(this.props.location.pathname.slice(20));
    const woQueryInfo = gql`
      query ($orderId: Int!){
        orderByOrderId(orderId: $orderId) {
          category
          status
          priority
          orderId
          requestLocal
          requestDepartment
        }
      }`;
    const { tabSelected } = this.state;

    return (
      <Query 
        query={woQueryInfo}
        variables={{orderId: orderId}}
      >{
        ({loading, error, data}) => {
        if(loading) return null
        if(error){
          console.log("Erro ao tentar baixar os dados da OS!");
          return null
        }
        const orderInfo = data;
        return(
          <AssetCard
            sectionName={'Ordem de Serviço'}
            sectionDescription={'Ficha descritiva'}
            handleCardButton={() => this.props.history.push('/manutencao/os')}
            buttonName={'Ordens de Serviço'}
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
                    <Col md="9" style={{ display: "flex", alignItems: "center" }}><span>{''}</span></Col>
                  </Row>
                </div>
                <div>
                  <Row>
                    <Col md="3" style={{ display: "flex", alignItems: "center", justifyContent: "flex-end" }}><span className="desc-sub">Código</span></Col>
                    <Col md="9" style={{ display: "flex", alignItems: "center" }}><span>{orderInfo.orderByOrderId.orderId}</span></Col>
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
                    <div>
                      Lista de manutenção.
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
    )
    }}</Query>
    );
  }
}

export default WorkOrderView;
