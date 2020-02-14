import React, { Component } from 'react';
import withDataFetching from '../../../components/DataFetch';
import withAccessToSession from '../../Authentication';
import { fetchAppliancesGQL, fetchAppliancesVariables } from './utils/dataFetchParameters';
import tableConfig from './utils/tableConfig';
import { customFilters, filterAttributes } from './utils/filterParameters';
import searchableAttributes from './utils/searchParameters';
import { compose } from 'redux';
import TableFilter from '../../../components/Tables/CustomTable/TableFilter';
import paths from '../../../paths';

class Appliances extends Component {
  render() {
    const data = this.props.data.queryResponse.nodes;

    return (
      <TableFilter
        title={"Equipamentos"}
        subtitle={"Lista de equipamentos do CASF"}
        buttonName={"Novo equipamento"}
        buttonPath={paths.appliance.create}
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