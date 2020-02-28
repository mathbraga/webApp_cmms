import React, { Component } from 'react';
import TableWithPagesUI from '../TableWithPages/TableWithPagesUI';
import SearchWithFilter from '../../Search/SearchWithFilter';
import withFilterLogic from '../../Filters/withFilterLogic';

import withSorting from '../TableWithSorting/withSorting';
import withPaginationLogic from '../TableWithPages/withPaginationLogic';
import withSearchLogic from '../../Search/withSearchLogic';
import withNestedData from '../NestedTable/withNestedData';

import { compose } from 'redux';

function createDataWithoutClosedItens(data, parents, openItens, tableConfig) {
  return (data.filter((item) => {
    const id = item[tableConfig.attForDataId];
    return parents[id].every((parent) => openItens[parent]);
  }));
}

class FullTable extends Component {
  constructor(props) {
    super(props);
    this.state = {
      openItens: {},
    }
  }

  handleNestedChildrenClick = (id) => () => {
    this.setState((prevState) => ({
      openItens: { ...prevState.openItens, [id]: !prevState.openItens[id] }
    }))
  }

  render() {
    const {
      tableConfig,
      selectedData,
      data,
      parents,
      searchableAttributes,
      searchTerm,
      handleChangeSearchTerm,
      customFilters,
      filterLogic,
      filterName,
      filterSavedId,
      filterAttributes,
      updateCurrentFilter
    } = this.props;
    const dataWithoutClosedItens = createDataWithoutClosedItens(data, parents, this.state.openItens, tableConfig);
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
          {...this.props}
          tableConfig={tableConfig}
          selectedData={selectedData}
          data={dataWithoutClosedItens}
          hasSearch={false}
          searchableAttributes={searchableAttributes}
          handleNestedChildrenClick={this.handleNestedChildrenClick}
          openItens={this.state.openItens}
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