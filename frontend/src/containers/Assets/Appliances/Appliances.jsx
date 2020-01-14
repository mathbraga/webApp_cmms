import React, { Component } from 'react';
import withDataFetching from '../../DataFetchingContainer';
import withAccessToSession from '../../Authentication';

const AppliancesWithData = withDataFetching(AppliancesUI)

class Appliances extends Component {
  render() {
    return (
      <AppliancesUI />
    );
  }
}

export default Appliances;