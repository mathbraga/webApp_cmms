import React, { Component } from 'react';
import AssetCard from '../../../src/components/Cards/AssetCard';
import FinalTable from '../TableWithPages/Table';
import SearchWithFilter from '../../../src/components/Search/SearchWithFilter';

export default class CardTableUI extends Component {
  render() {
    const {
      title,
      subtitle,
      buttonName,
      tableConfig,
      goToPage,
      pageCurrent,
      setGoToPage,
      setCurrentPage,
      updateCurrentFilter,
      filterSavedId,
      searchTerm,
      handleChangeSearchTerm,
      handleCardButton,
      filterLogic,
      filterName,
      numberOfitems,
      customFilters,
      filterAttributes,
      hasAssetCard = true,
      data
    } = this.props;

    if (hasAssetCard) {
      return (
        <AssetCard
          sectionName={title || 'Nome'}
          sectionDescription={subtitle || 'Descrição dos items'}
          handleCardButton={handleCardButton}
          buttonName={buttonName || 'Botão'}
        >
          <SearchWithFilter
            updateCurrentFilter={updateCurrentFilter}
            filterSavedId={filterSavedId}
            searchTerm={searchTerm}
            handleChangeSearchTerm={handleChangeSearchTerm}
            filterLogic={filterLogic}
            filterName={filterName}
            numberOfitems={numberOfitems}
            customFilters={customFilters}
            filterAttributes={filterAttributes}
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

    return (
      <div>
        <SearchWithFilter
          updateCurrentFilter={updateCurrentFilter}
          filterSavedId={filterSavedId}
          searchTerm={searchTerm}
          handleChangeSearchTerm={handleChangeSearchTerm}
          filterLogic={filterLogic}
          filterName={filterName}
          numberOfitems={numberOfitems}
          customFilters={customFilters}
          filterAttributes={filterAttributes}
        />
        <FinalTable
          tableConfig={tableConfig}
          data={data}
          setGoToPage={setGoToPage}
          goToPage={goToPage}
          setCurrentPage={setCurrentPage}
          pageCurrent={pageCurrent}
        />
      </div>
    );
  }
}