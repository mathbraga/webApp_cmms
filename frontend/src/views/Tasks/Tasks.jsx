import React, { Component } from 'react';
import tableConfig from './utils/tableConfig';
import { customFilters, filterAttributes } from './utils/filterParameters';
import searchableAttributes from './utils/searchParameters';
import { compose } from 'redux';
import TableFilter from '../../components/Tables/CustomTable/TableFilter';
import props from './props';
import { withProps, withGraphQL, withQuery } from '../../hocs';
import paths from '../../paths';

class Tasks extends Component {
  render() {
    const data = this.props.data.queryResponse.nodes;

    return (
      <TableFilter
        title={"Ordens de Serviço"}
        subtitle={"Lista de ordens de serviço de engenharia"}
        buttonName={"Nova OS"}
        buttonPath={paths.task.create}
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
)(Tasks);