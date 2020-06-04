import React, { Component } from 'react';
// import DescriptionTable from '../../../../components/Descriptions/DescriptionTable';
// import { itemsMatrixAssets } from '../utils/descriptionMatrix';
import tableConfig from '../utils/assetTab/tableConfig';
// import { customFilters, filterAttributes } from '../utils/assetTab/filterParameters';
import searchableAttributes from '../utils/assetTab/searchParameters';
// import TableFilter from '../../../../components/Tables/CustomTable/TableFilter';
import AssetTemplateTab from '../../../components/Tabs/AssetTab/AssetsTemplateTab';
import { itemsMatrixAssets } from '../utils/assetTab/descriptionMatrix';

import withPrepareData from '../../../components/Formating/withPrepareData';
import withSelectLogic from '../../../components/Selection/withSelectLogic';
import CustomTable from '../../../components/Tables/CustomTable';

import PaneTitle from '../../../components/TabPanes/PaneTitle';
import PaneTextContent from '../../../components/TabPanes/PaneTextContent';

import { compose } from 'redux';

import './Tabs.css';

class AssetTab extends Component {
  constructor(props) {
    super(props);
    this.state = {
      editFormOpen: false,
    }
  }
  render() {
    const data = this.props.data.assets;
    return (
      <>
        <div className="tabpane-container">
          <PaneTitle 
            title={'Tabela de Ativos'}
          />
          <AnimateHeight 
            duration={300}
            height={heightAdd}
          >
            <div className="tabpane__content">
              <AddSupplyForm 
                visible={true}
                toggleForm={this.toggleAddForm}
              />
            </div>
          </AnimateHeight>
          <AnimateHeight 
            duration={300}
            height={heightEdit}
          >
            <div className="tabpane__content">
              <EditSupplyForm 
                visible={true}
                toggleForm={this.toggleEditForm}
              />
            </div>
          </AnimateHeight>
          {(editFormOpen) && (
            <PaneTitle 
              title={'Tabela de Ativos'}
            />
          )}
          <div className="tabpane__content">
            <PaneTextContent 
              numColumns='2' 
              itemsMatrix={itemsMatrixAssets()}
            />
          </div>
          <div className="tabpane__content__table">
            <CustomTable
              type={'pages-with-search'}
              tableConfig={tableConfig}
              searchableAttributes={searchableAttributes}
              selectedData={this.props.selectedData}
              handleSelectData={this.props.handleSelectData}
              data={data}
              disableSorting
            />
          </div>
        </div>
      </>
    );
  }
}

export default compose(
  withPrepareData(tableConfig),
  withSelectLogic
)(AssetTab);