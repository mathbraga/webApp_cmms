import React, { Component } from 'react';
import withDataFetching from '../../DataFetchContainer';
import { fetchAppliancesGQL, fetchAppliancesVariables } from './utils/dataFetchParameters';
import tableConfig from './utils/tableConfig';
import { customFilters, filterAttributes } from './utils/filterParameters';
import searchableAttributes from './utils/searchParameters';
import { compose } from 'redux';
import CardWithTable from '../../TableContainer/CardWithTable';

class Appliances extends Component {
  render() {
    const data = this.props.allAssets.nodes;

    return (
      <CardWithTable
        tableConfig={tableConfig}
        customFilters={customFilters}
        filterAttributes={filterAttributes}
        searchableAttributes={searchableAttributes}
        data=
      />
    );
  }
}

export default compose(
  withDataFetching(fetchAppliancesGQL, fetchAppliancesVariables)
)(Appliances);