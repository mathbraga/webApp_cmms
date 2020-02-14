import React, { Component } from 'react';
import tableConfig from './utils/tableConfig';
import { customFilters, filterAttributes } from './utils/filterParameters';
import searchableAttributes from './utils/searchParameters';
import { compose } from 'redux';
import TableFilter from '../../components/Tables/CustomTable/TableFilter';
import props from './props';
import { withProps, withGraphQL, withQuery } from '../../hocs';

class Appliances extends Component {
  render() {
    const data = this.props.data.queryResponse.nodes;

    return (
      <TableFilter
        title={"Especificações Técnicas"}
        subtitle={"Lista de especificações técnicas"}
        buttonName={"Novo Item"}
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