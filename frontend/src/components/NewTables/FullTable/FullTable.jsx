import React, { Component } from 'react';
import TableWithPagesUI from '../TableWithPages/TableWithPagesUI';
import SearchWithFilter from '../../Search/SearchWithFilter';
import withFilterLogic from '../../Filters/withFilterLogic';

class FullTable extends Component {
  render() {
    const {
      tableConfig,
      selectedData,
      data,
      searchableAttributes,
      searchTerm,
      handleChangeSearchTerm,
      numberOfItens,
      customFilters,
      filterLogic,
      filterName,
      filterSavedId,
      filterAttributes,
    } = this.props;
    return (
      <SearchWithFilter
        updateCurrentFilter={updateCurrentFilter}
        filterSavedId={filterSavedId}
        searchTerm={searchTerm}
        handleChangeSearchTerm={handleChangeSearchTerm}
        filterLogic={filterLogic}
        filterName={filterName}
        numberOfItens={numberOfItens}
        customFilters={customFilters}
        filterAttributes={filterAttributes}
      />
      <TableWithPagesUI
        tableConfig={tableConfig}
        selectedData={selectedData}
        data={data}
        hasSearch={tableConfig.hasSearch}
        searchableAttributes={searchableAttributes}
        {...this.props}
      />
    );
  }
}

export default compose(
  withSorting,
  withPaginationLogic,
  withSearchLogic,
  withFilterLogic,
)(FullTable);