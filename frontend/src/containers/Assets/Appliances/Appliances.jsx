import React, { Component } from 'react';
import withDataFetching from '../../DataFetchContainer';
import withAccessToSession from '../../Authentication';
import AppliancesUI from './AppliancesUI';
import { fetchAppliancesGQL, fetchAppliancesVariables } from './dataFetchParameters';
import tableConfig from './appliancesTableConfig';

const AppliancesUIWithData = withDataFetching(AppliancesUI, fetchAppliancesGQL, fetchAppliancesVariables);
const AppliancesUIWithDataAndSession = withAccessToSession(AppliancesUIWithData);

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
  }

  setGoToPage(page) {
    this.setState({ goToPage: page });
  }

  setCurrentPage(pageCurrent) {
    this.setState({ pageCurrent: pageCurrent }, () => {
      this.setState({ goToPage: pageCurrent });
    });
  }

  // TO DO: Put all the extra logic here.

  render() {
    return (
      <AppliancesUIWithDataAndSession
        tableConfig={tableConfig}
        goToPage={this.state.goToPage}
        pageCurrent={this.state.pageCurrent}
        setGoToPage={this.setGoToPage}
        setCurrentPage={this.setCurrentPage}
        updateCurrentFilter={}
        filterSavedId={this.state.filterSavedId}
        searchTerm={this.state.searchTerm}
        handleChangeSearchTerm={}
        filterLogic={this.state.filterLogic}
        filterName={this.state.filterName}
        numberOfItens={}
      />
    );
  }
}

export default Appliances;