import React from 'react';
import tableConfig from './utils/tableConfig';
import { customFilters, filterAttributes } from './utils/filterParameters';
import searchableAttributes from './utils/searchParameters';
import { compose } from 'redux';
import props from './props';
import { withProps, withGraphQL, withQuery } from '../../hocs';
import paths from '../../paths';
import withSelectLogic from '../../components/Selection/withSelectLogic';
import { withRouter } from "react-router-dom";
import withPrepareData from '../../components/Formating/withPrepareData';
import withDataAccess from './utils/withDataAccess';
import CustomTable from '../../components/Tables/CustomTable';
import AssetCard from '../../components/Cards/AssetCard';

import { useQuery, useEfect } from '@apollo/react-hooks';

import { TASKS_QUERY } from './graphql/gql';
import prepareData from '../../components/DataManipulation/prepareData';


const Tasks = (props) => {
  const { loading, data: { allTaskData: { nodes: rawData } = {} } = {} } = useQuery(TASKS_QUERY);
  const data = prepareData(rawData, tableConfig);
  
  return (
    <AssetCard
      sectionName={"Tarefas"}
      sectionDescription={"Lista de ordens de serviço de engenharia"}
      handleCardButton={() => { props.history.push(paths.task.create) }}
      buttonName={"Nova OS"}
    >
      {
        !loading && (
          <CustomTable
            type={'full'}
            tableConfig={tableConfig}
            customFilters={customFilters}
            filterAttributes={filterAttributes}
            searchableAttributes={searchableAttributes}
            selectedData={props.selectedData}
            handleSelectData={props.handleSelectData}
            data={data}
          />
        )
      }
    </AssetCard>
  );
}

export default compose(
  withRouter
)(Tasks);