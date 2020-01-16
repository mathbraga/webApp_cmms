import React, { Component } from 'react';
import withDataFetching from '../../DataFetchContainer';
import withAccessToSession from '../../Authentication';
import AppliancesUI from './AppliancesUI';
import { fetchAppliancesGQL, fetchAppliancesVariables } from './dataFetchParameters';
import tableConfig from './tableConfig';
import searchList from '../../../utils/search/searchList';
import filterList from '../../../utils/filter/filter';
import { customFilters, filterAttributes } from './filterParameters';
import searchableAttributes from './searchParameters';

const ENTRIES_PER_PAGE = 15;

class Appliances extends Component {
  constructor(props) {
    super(props);
    this.state = {
      goToPage: 1,
      pageCurrent: 1,
      filterSavedId: null,
      searchTerm: "",
      filterLogic: [],
    }

    this.setGoToPage = this.setGoToPage.bind(this);
    this.setCurrentPage = this.setCurrentPage.bind(this);
    this.updateCurrentFilter = this.updateCurrentFilter.bind(this);
    this.handleChangeSearchTerm = this.handleChangeSearchTerm.bind(this);
  }

  setGoToPage(page) {
    this.setState({ goToPage: page });
  }

  setCurrentPage(pageCurrent) {
    this.setState({ pageCurrent: pageCurrent }, () => {
      this.setState({ goToPage: pageCurrent });
    });
  }

  updateCurrentFilter(filterLogic, filterName, filterId = null) {
    this.setState({
      filterLogic,
      filterName,
      filterSavedId: filterId,
      pageCurrent: 1,
      goToPage: 1,
    });
  }

  handleChangeSearchTerm(event) {
    this.setState({ searchTerm: event.target.value, pageCurrent: 1, goToPage: 1 });
  }

  // TO DO: Put all the extra logic here.

  render() {
    const data = this.props.data.allAssets.nodes;

    const dataWithFilter = this.state.filterLogic.length > 0 ? filterList(data, this.state.filterLogic) : data;
    const dataWithSearchAndFilter = searchList(dataWithFilter, searchableAttributes, this.state.searchTerm);
    const totalOfPages = Math.floor(dataWithSearchAndFilter.length / ENTRIES_PER_PAGE) + 1;

    console.log("Data: ", dataWithSearchAndFilter);

    return (
      <AppliancesUI
        tableConfig={tableConfig}
        goToPage={this.state.goToPage}
        pageCurrent={this.state.pageCurrent}
        setGoToPage={this.setGoToPage}
        setCurrentPage={this.setCurrentPage}
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

const AppliancesWithData = withDataFetching(Appliances, fetchAppliancesGQL, fetchAppliancesVariables);
const AppliancesWithDataAndSession = withAccessToSession(AppliancesWithData);

export default AppliancesWithDataAndSession;