import React, { Component } from 'react';
import tableConfig from './utils/tableConfig';
import { customFilters, filterAttributes } from './utils/filterParameters';
import searchableAttributes from './utils/searchParameters';
import { compose } from 'redux';
import CustomTable from '../../components/NewTables/CustomTable';
import AssetCard from '../../components/Cards/AssetCard';
import props from './props';
import paths from '../../paths';
import { withProps, withQuery, withGraphQL } from '../../hocs';
import withSelectLogic from '../../components/Selection/withSelectLogic';
import { withRouter } from "react-router-dom";

class Facilities extends Component {
  render() {
    const data = this.props.data.queryResponse.nodes;

    return (
      <AssetCard
        sectionName={"Edifícios / Áreas"}
        sectionDescription={"Lista de áreas do CASF"}
        handleCardButton={() => { this.props.history.push(paths.facility.create) }}
        buttonName={"Nova área"}
      >
        <CustomTable
          type={'full'}
          tableConfig={tableConfig}
          customFilters={customFilters}
          filterAttributes={filterAttributes}
          searchableAttributes={searchableAttributes}
          selectedData={this.props.selectedData}
          handleSelectData={this.props.handleSelectData}
          data={data}
        />
      </AssetCard>
    );
  }
}

export default compose(
  withProps(props),
  withGraphQL,
  withQuery,
  withRouter,
  withSelectLogic
)(Facilities);