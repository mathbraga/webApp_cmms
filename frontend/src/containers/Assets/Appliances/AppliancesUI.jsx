import React, { Component } from 'react';

export default class AppliancesUI extends Component {
  render() {
    <AssetCard
      sectionName={'Equipamentos'}
      sectionDescription={'Lista de equipamentos'}
      handleCardButton={() => { console.log('OK!') }}
      buttonName={'Novo Equipamento'}
    >
      Hey!
    </AssetCard>
  }
}