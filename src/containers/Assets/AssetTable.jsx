import React, { Component } from 'react';
import AssetCard from "../../components/Cards/AssetCard";

class AssetTable extends Component {
  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    return (
      <AssetCard
        sectionName={'Edifícios'}
        sectionDescription={'Endereçamento do Senado Federal'}
        handleCardButton={() => { }}
        buttonName={'Novo Edifício'}
      >
        Teste
      </AssetCard>
    );
  }
}

export default AssetTable;