import React, { Component } from 'react';
import tableConfig from './utils/tableConfig';
import { customFilters, filterAttributes } from './utils/filterParameters';
import searchableAttributes from './utils/searchParameters';
import { compose } from 'redux';
import { withProps, withGraphQL, withQuery } from '../../hocs';
import props from './props';
import withSelectLogic from '../../components/Selection/withSelectLogic';
import { withRouter } from "react-router-dom";
import withPrepareData from '../../components/Formating/withPrepareData';
import withDataAccess from './utils/withDataAccess';
import CustomTable from '../../components/NewTables/CustomTable';
import AssetCard from '../../components/Cards/AssetCard';


class Contracts extends Component {
  render() {
    return (
      <AssetCard
        sectionName={"Contratos"}
        sectionDescription={"Lista de contratos de engenharia"}
        handleCardButton={() => { console.log("OK") }}
        buttonName={"Novo Contrato"}
      >
        <CustomTable
          type={'full'}
          tableConfig={tableConfig}
          customFilters={customFilters}
          filterAttributes={filterAttributes}
          searchableAttributes={searchableAttributes}
          selectedData={this.props.selectedData}
          handleSelectData={this.props.handleSelectData}
          data={this.props.data}
        />
      </AssetCard>
    );
  }
}

export default compose(
  withProps(props),
  withGraphQL,
  withQuery,
  withDataAccess,
  withPrepareData(tableConfig),
  withRouter,
  withSelectLogic
)(Contracts);