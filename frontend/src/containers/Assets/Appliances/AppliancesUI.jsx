import React, { Component } from 'react';
import AssetCard from '../../../components/Cards/AssetCard';
import FinalTable from '../../../components/Tables/FinalTable';

export default class AppliancesUI extends Component {
  render() {
    const {
      tableConfig,
      goToPage,
      pageCurrent,
      setGoToPage,
      setCurrentPage
    } = this.props;
    const data = this.props.data.allAssets.nodes;
    console.log("Data: ", data);

    return (
      <AssetCard
        sectionName={'Equipamentos'}
        sectionDescription={'Lista de equipamentos'}
        handleCardButton={() => { console.log('OK!') }}
        buttonName={'Novo Equipamento'}
      >
        <FinalTable
          tableConfig={tableConfig}
          data={data}
          setGoToPage={setGoToPage}
          goToPage={goToPage}
          setCurrentPage={setCurrentPage}
          pageCurrent={pageCurrent}
        />
      </AssetCard>
    );
  }
}