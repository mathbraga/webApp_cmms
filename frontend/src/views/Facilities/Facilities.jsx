import React, { Component } from 'react';
import tableConfig from './utils/tableConfig';
import { customFilters, filterAttributes } from './utils/filterParameters';
import searchableAttributes from './utils/searchParameters';
import { compose } from 'redux';
import TableFilter from '../../components/Tables/CustomTable/TableFilter';
import props from './props';
import paths from '../../paths';
import { withProps, withQuery, withGraphQL } from '../../hocs';

class Facilities extends Component {
  render() {
    const data = this.props.data.queryResponse.nodes;

    return (
      <TableFilter
        title={"Edifícios / Áreas"}
        subtitle={"Lista de áreas do CASF"}
        buttonName={"Nova área"}
        buttonPath={paths.facility.create}
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
)(Facilities);