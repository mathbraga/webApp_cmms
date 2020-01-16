import React, { Component } from 'react';
import withDataFetching from '../../DataFetchContainer';
import withAccessToSession from '../../Authentication';
import { fetchAppliancesGQL, fetchAppliancesVariables } from './utils/dataFetchParameters';
import tableConfig from './utils/tableConfig';
import { customFilters, filterAttributes } from './utils/filterParameters';
import searchableAttributes from './utils/searchParameters';
import { compose } from 'redux';
import CardWithTable from '../../TableContainer/CardWithTable';

class Appliances extends Component {
  render() {
    const data = this.props.data.allAssets.nodes;

    return (
      <CardWithTable
        tableConfig={tableConfig}
        customFilters={customFilters}
        filterAttributes={filterAttributes}
        searchableAttributes={searchableAttributes}
        data={data}
      />
    );
  }
}

export default compose(
  withAccessToSession,
  withDataFetching(fetchAppliancesGQL, fetchAppliancesVariables)
)(Appliances);