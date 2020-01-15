import React, { Component } from 'react';
import AssetCard from '../../../components/Cards/AssetCard';
import FinalTable from '../../../components/Tables/FinalTable';
import SearchWithFilter from '../../../components/Search/SearchWithFilter';

export default class AppliancesUI extends Component {
  render() {
    const {
      tableConfig,
      goToPage,
      pageCurrent,
      setGoToPage,
      setCurrentPage,
      updateCurrentFilter,
      filterSavedId,
      searchTerm,
      handleChangeSearchTerm,
      filterLogic,
      filterName,
      numberOfItens,
      data
    } = this.props;

    return (
      <AssetCard
        sectionName={'Equipamentos'}
        sectionDescription={'Lista de equipamentos'}
        handleCardButton={() => { console.log('OK!') }}
        buttonName={'Novo Equipamento'}
      >
        <SearchWithFilter
          updateCurrentFilter={updateCurrentFilter}
          filterSavedId={filterSavedId}
          searchTerm={searchTerm}
          handleChangeSearchTerm={handleChangeSearchTerm}
          filterLogic={filterLogic}
          filterName={filterName}
          numberOfItens={numberOfItens}
        />
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