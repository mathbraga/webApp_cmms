import React, { Component } from 'react';
import AssetCard from '../../../components/Cards/AssetCard';

export default class AppliancesUI extends Component {
  render() {
    const data = this.props.data.allAssets.nodes;

    return (
      <AssetCard
        sectionName={'Equipamentos'}
        sectionDescription={'Lista de equipamentos'}
        handleCardButton={() => { console.log('OK!') }}
        buttonName={'Novo Equipamento'}
      >
        Hey!
      </AssetCard>
    );
  }
}