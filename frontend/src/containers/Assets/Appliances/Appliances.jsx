import React, { Component } from 'react';
import withDataFetching from '../../DataFetchingContainer';
import withAccessToSession from '../../Authentication';
import { fetchAppliancesGQL, fetchAppliancesVariables } from './dataFetchingParameters';

const AppliancesWithData = withDataFetching(AppliancesUI, fetchAppliancesGQL);

class Appliances extends Component {
  render() {
    return (
      <AppliancesUI />
    );
  }
}

export default Appliances;