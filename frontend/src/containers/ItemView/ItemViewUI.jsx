import React, { Component } from 'react';

export default class ItemViewUI extends Component {
  state = {}
  render() {
    return ( 
      <div className="asset-container">
        <AssetCard
          sectionName={'Edifício / Área'}
          sectionDescription={'Ficha descritiva do imóvel'}
          handleCardButton={() => {}}
          buttonName={'Edifícios'}
        >
          <h1>Hello!</h1>
        </AssetCard>
      </div>
    );
  }
}