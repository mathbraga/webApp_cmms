import React, { Component } from 'react';
import tableConfig from './utils/tableConfig';
import { customFilters, filterAttributes } from './utils/filterParameters';
import searchableAttributes from './utils/searchParameters';
import { compose } from 'redux';
import TableFilter from '../../components/Tables/CustomTable/TableFilter';
import paths from '../../paths';
import props from './props';
import { withProps, withQuery, withGraphQL } from '../../hocs';

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
  withProps(props),
  withGraphQL,
  withQuery
)(Appliances);