import React, { Component } from 'react';
import AssetCard from '../../../components/Cards/AssetCard';

export default class AppliancesUI extends Component {
  render() {
    console.log("Props: ", this.props);
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