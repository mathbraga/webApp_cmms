import React, { Component } from 'react';
import DescriptionTable from '../../../components/Descriptions/DescriptionTable';
import { itemsMatrixTasks } from '../utils/descriptionMatrix';
import tableConfig from '../utils/tasksTab/tableConfig';
import { customFilters, filterAttributes } from '../utils/tasksTab/filterParameters';
import searchableAttributes from '../utils/tasksTab/searchParameters';
import withDataAccess from '../utils/tasksTab/withDataAccess';
import CustomTable from '../../../components/NewTables/CustomTable';
import withPrepareData from '../../../components/Formating/withPrepareData';
import withSelectLogic from '../../../components/Selection/withSelectLogic';
import { compose } from 'redux';
import './Tabs.css';

class TasksTab extends Component {
  state = {}
  render() {
    return (
      <>
        <DescriptionTable
          title={'Lista de Ordens de Serviço'}
          numColumns={2}
          itemsMatrix={itemsMatrixTasks(this.props.data)}
        />
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
      </>
    );
  }
}

export default compose(
  withDataAccess,
  withPrepareData(tableConfig),
  withSelectLogic
)(TasksTab);