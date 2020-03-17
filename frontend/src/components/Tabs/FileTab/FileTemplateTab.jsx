import React, { Component } from 'react';
import DescriptionTable from '../../Descriptions/DescriptionTable';
import { itemsMatrixFiles } from './utils/descriptionMatrix';
import searchableAttributes from './utils/searchParameters';
import tableConfig from './utils/tableConfig';
import CustomTable from '../../Tables/CustomTable';
import withPrepareData from '../../Formating/withPrepareData';
import withSelectLogic from '../../Selection/withSelectLogic';
import { compose } from 'redux';

class MaintenanceTemplateTab extends Component {
  render() {
    const { data } = this.props;
    return (
      <>
        <DescriptionTable
          title={'Lista de Arquivos'}
          numColumns={2}
          itemsMatrix={itemsMatrixFiles(data)}
        />
        <CustomTable
          type={'pages-with-search'}
          tableConfig={tableConfig}
          searchableAttributes={searchableAttributes}
          data={data}
        />
      </>
    );
  }
}

export default compose(
  withPrepareData(tableConfig),
  withSelectLogic
)(MaintenanceTemplateTab);