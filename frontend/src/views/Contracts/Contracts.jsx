import React, { Component } from 'react';
import tableConfig from './utils/tableConfig';
import { customFilters, filterAttributes } from './utils/filterParameters';
import searchableAttributes from './utils/searchParameters';
import { compose } from 'redux';
import TableFilter from '../../components/Tables/CustomTable/TableFilter';
import { withProps, withGraphQL, withQuery } from '../../hocs';
import props from './props';

class Contracts extends Component {
  render() {
    const data = this.props.data.queryResponse.nodes;

    return (
      <TableFilter
        title={"Contratos"}
        subtitle={"Lista de contratos de engenharia"}
        buttonName={"Novo Contrato"}
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
)(Contracts);