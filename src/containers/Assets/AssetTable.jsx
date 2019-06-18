import React, { Component } from 'react';
import { Row, Col } from "reactstrap";
import AssetCard from "../../components/Cards/AssetCard";

class AssetTable extends Component {
  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    return (
      <AssetCard
        sectionName={'Edifícios e áreas'}
        sectionDescription={'Endereçamento do Senado Federal'}
        handleCardButton={() => { }}
        buttonName={'Cadastrar Área'}
      >
        <Row>
          <Col md="2">1</Col>
          <Col md="4">2</Col>
          <Col md="6">3</Col>
        </Row>
      </AssetCard>
    );
  }
}

export default AssetTable;