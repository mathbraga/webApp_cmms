import React, { Component } from 'react';
import withDataFetching from '../../DataFetchContainer';
import withAccessToSession from '../../Authentication';
import withPaginationLogic from '../../PageLogicContainer';
import AppliancesUI from './AppliancesUI';
import { fetchAppliancesGQL, fetchAppliancesVariables } from './utils/dataFetchParameters';
import tableConfig from './utils/tableConfig';
import searchList from '../../../utils/search/searchList';
import filterList from '../../../utils/filter/filter';
import { customFilters, filterAttributes } from './utils/filterParameters';
import searchableAttributes from './utils/searchParameters';
import { compose } from 'redux';

const ENTRIES_PER_PAGE = 15;

class Appliances extends Component {
  constructor(props) {
    super(props);
    this.state = {
      filterSavedId: null,
      searchTerm: "",
      filterLogic: [],
    }

    this.updateCurrentFilter = this.updateCurrentFilter.bind(this);
    this.handleChangeSearchTerm = this.handleChangeSearchTerm.bind(this);
  }

  updateCurrentFilter(filterLogic, filterName, filterId = null) {
    this.setState({
      filterLogic,
      filterName,
      filterSavedId: filterId
    }, () => this.props.paginationLogic.setCurrentPage(1));
  }

  handleChangeSearchTerm(event) {
    this.setState({
      searchTerm: event.target.value
    }, () => this.props.paginationLogic.setCurrentPage(1));
  }

  // Put all the extra logic here.

  render() {
    const data = this.props.data.allAssets.nodes;
    const { paginationLogic } = this.props;

    const dataWithFilter = this.state.filterLogic.length > 0 ? filterList(data, this.state.filterLogic) : data;
    const dataWithSearchAndFilter = searchList(dataWithFilter, searchableAttributes, this.state.searchTerm);
    const totalOfPages = Math.floor(dataWithSearchAndFilter.length / ENTRIES_PER_PAGE) + 1;


    return (
      <AppliancesUI
        tableConfig={tableConfig}
        goToPage={paginationLogic.goToPage}
        pageCurrent={paginationLogic.pageCurrent}
        setGoToPage={paginationLogic.setGoToPage}
        setCurrentPage={paginationLogic.setCurrentPage}
        updateCurrentFilter={this.updateCurrentFilter}
        filterSavedId={this.state.filterSavedId}
        searchTerm={this.state.searchTerm}
        handleChangeSearchTerm={this.handleChangeSearchTerm}
        filterLogic={this.state.filterLogic}
        filterName={this.state.filterName}
        numberOfItens={totalOfPages}
        data={dataWithSearchAndFilter}
        customFilters={customFilters}
        filterAttributes={filterAttributes}
      />
    );
  }
}

export default compose(
  withPaginationLogic,
  withAccessToSession,
  withDataFetching(fetchAppliancesGQL, fetchAppliancesVariables)
)(Appliances);