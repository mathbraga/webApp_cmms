import React, { Component } from "react";
import getWorkOrder from "../../utils/maintenance/getWorkOrder";
import AssetCard from "../../components/Cards/AssetCard";
import { Row, Col, Button, Badge, Nav, NavItem, NavLink, TabContent, TabPane, CustomInput } from "reactstrap";
import './WorkOrderView.css';

import { Query } from 'react-apollo';
import gql from 'graphql-tag';

const descriptionImage = require("../../assets/img/test/order_picture.png");

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
    }
    this.handleClickOnNav = this.handleClickOnNav.bind(this);
  }

  handleClickOnNav(tabSelected) {
    this.setState({ tabSelected: tabSelected });
  }

  render() {
    const orderId = Number(this.props.location.pathname.slice(20));
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
          createdAt
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
          updatedAt
        }
      }
    `;
    const { tabSelected } = this.state;

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
            console.log("WO Data: ", orderInfo);
            return (
              <AssetCard
                sectionName={'Ordem de Serviço'}
                sectionDescription={'Ficha descritiva do serviço'}
                handleCardButton={() => this.props.history.push('/manutencao/os')}
                buttonName={'Ordens de Serviço'}
              >
                <Row>
                  <Col md="2">
                    <div className="desc-box">
                      <img className="desc-image" src={descriptionImage} alt="Ar-condicionado" />
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
                  <div style={{ margin: "20px", width: "100%" }}>
                    <Nav tabs>
                      <NavItem>
                        <NavLink onClick={() => { this.handleClickOnNav("info") }} active={tabSelected === "info"} >Informações Gerais</NavLink>
                      </NavItem>
                      <NavItem>
                        <NavLink onClick={() => { this.handleClickOnNav("location") }} active={tabSelected === "location"} >Localização</NavLink>
                      </NavItem>
                      <NavItem>
                        <NavLink onClick={() => { this.handleClickOnNav("maintenance") }} active={tabSelected === "maintenance"} >Ativos</NavLink>
                      </NavItem>
                      <NavItem>
                        <NavLink onClick={() => { this.handleClickOnNav("warranty") }} active={tabSelected === "warranty"} >Arquivos</NavLink>
                      </NavItem>
                      <NavItem>
                        <NavLink onClick={() => { this.handleClickOnNav("asset") }} active={tabSelected === "asset"} >Solicitante</NavLink>
                      </NavItem>
                      <NavItem>
                        <NavLink onClick={() => { this.handleClickOnNav("file") }} active={tabSelected === "file"} >Atribuido para</NavLink>
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
