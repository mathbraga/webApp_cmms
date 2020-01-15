import withDataFetching from '../../DataFetchContainer';
import withAccessToSession from '../../Authentication';
import { fetchAppliancesGQL, fetchAppliancesVariables } from './dataFetchParameters';
import React, { Component } from 'react';
import AppliancesUI from './AppliancesUI';

const AppliancesUIWithData = withDataFetching(AppliancesUI, fetchAppliancesGQL, fetchAppliancesVariables);
const AppliancesUIWithDataAndSession = withAccessToSession(AppliancesUIWithData);

const tableConfig = {
  numberOfColumns: 3,
  checkbox: true,
  columnObjects: [
    { name: 'name', description: 'Equipamento', style: { width: "30%" }, className: "", data: ['name', 'assetSf'] },
    { name: 'model', description: 'Modelo', style: { width: "10%" }, className: "text-center", data: ['model'] },
    { name: 'manufacturer', description: 'Fabricante', style: { width: "10%" }, className: "text-center", data: ['manufacturer'] },
  ],
};

class Appliances extends Component {
  constructor(props) {
    super(props);
    this.state = {
      goToPage: 1,
      pageCurrent: 1,
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
      />
    );
  }
}

export default Appliances;