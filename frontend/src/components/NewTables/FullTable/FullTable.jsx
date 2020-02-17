import React, { Component } from 'react';
import TableWithPagesUI from '../TableWithPages/TableWithPagesUI';
import SearchWithFilter from '../../Search/SearchWithFilter';
import withFilterLogic from '../../Filters/withFilterLogic';

import withSorting from '../TableWithSorting/withSorting';
import withPaginationLogic from '../TableWithPages/withPaginationLogic';
import withSearchLogic from '../../Search/withSearchLogic';
import withNestedData from '../NestedTable/withNestedData';

import { compose } from 'redux';

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
      updateCurrentFilter
    } = this.props;
    console.log("Data: ", data);
    return (
      <>
        <SearchWithFilter
          updateCurrentFilter={updateCurrentFilter}
          filterSavedId={filterSavedId}
          searchTerm={searchTerm}
          handleChangeSearchTerm={handleChangeSearchTerm}
          filterLogic={filterLogic}
          filterName={filterName}
          numberOfItens={data.length}
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
      </>
    );
  }
}

export default compose(
  withSorting,
  withNestedData,
  withPaginationLogic,
  withSearchLogic,
  withFilterLogic,
)(FullTable);