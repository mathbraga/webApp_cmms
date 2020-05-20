import React, { Component } from 'react';

import DispatchForm from '../../../components/NewForms/DispatchForm'
import StatusForm from '../../../components/NewForms/StatusForm'
import PaneTitle from '../../../components/TabPanes/PaneTitle'
import PaneTextContent from '../../../components/TabPanes/PaneTextContent';
import { itemsMatrixAssetsHierachy } from '../utils/dispatchTab/descriptionMatrix';
import './Tabs.css'

import CustomTable from '../../../components/Tables/CompactTable/CompactTable';
import tableConfig from '../utils/dispatchTab/tableConfig';
import searchableAttributes from '../utils/dispatchTab/searchParameters';

import AnimateHeight from 'react-animate-height';

class AssignTab extends Component {
  constructor(props) {
    super(props);
    this.state = {
      dispatchFormOpen: false,
      statusFormOpen: false,
    };
    this.toggleDispatchForm = this.toggleDispatchForm.bind(this);
    this.toggleStatusForm = this.toggleStatusForm.bind(this);
  }

  toggleDispatchForm() {
    this.setState(prevState => ({
      dispatchFormOpen: !prevState.dispatchFormOpen,
      statusFormOpen: false
    }));
  }

  toggleStatusForm() {
    this.setState(prevState => ({
      statusFormOpen: !prevState.statusFormOpen,
      dispatchFormOpen: false
    }));
  }

  render() {
    const data = this.props.data.assets;
    const { dispatchFormOpen, statusFormOpen } = this.state;

    const actionButtons = {
      statusFormOpen: [
        {name: 'Cancelar', color: 'danger', onClick: this.toggleStatusForm}
      ],
      dispatchFormOpen: [
        {name: 'Cancelar', color: 'danger', onClick: this.toggleDispatchForm}
      ],
      noFormOpen: [
        {name: 'Tramitar Tarefa', color: 'success', onClick: this.toggleDispatchForm},
        {name: 'Alterar Status', color: 'primary', onClick: this.toggleStatusForm}
      ],
    };
    const openedForm = dispatchFormOpen ? 'dispatchFormOpen' : (statusFormOpen ? 'statusFormOpen' : 'noFormOpen');
    const heightDispatch = openedForm === 'dispatchFormOpen' ? 'auto' : 0;
    const heightStatus = openedForm === 'statusFormOpen' ? 'auto' : 0;

    return (
      <>
        <div className="tabpane-container">
          <PaneTitle 
            actionButtons={actionButtons[openedForm]}
            title={dispatchFormOpen ? 'Tramitar Tarefa' : (statusFormOpen ? 'Alterar Status' : 'Situação Atual')}
          />
          <AnimateHeight 
          duration={300}
          height={heightDispatch}
          >
            <div className="tabpane__content">
              <DispatchForm 
                visible={true}
                toggleForm={this.toggleDispatchForm}
              />
            </div>
          </AnimateHeight>
          <AnimateHeight 
            duration={300}
            height={heightStatus}
          >
            <div className="tabpane__content">
              <StatusForm 
                visible={true}
                toggleForm={this.toggleStatusForm}
              />
            </div>
          </AnimateHeight>
          {(statusFormOpen || dispatchFormOpen) && (
            <PaneTitle 
              title={'Situação Atual'}
            />
          )}
          <div className="tabpane__content">
            <PaneTextContent 
              numColumns='2' 
              itemsMatrix={itemsMatrixAssetsHierachy(data)}
            />
          </div>
          <PaneTitle 
            title={'Histórico'}
          />
          <div className="tabpane__content">
            {/* <CustomTable
              type={'pages-with-search'}
              tableConfig={tableConfig}
              customFilters={customFilters}
              filterAttributes={filterAttributes}
              searchableAttributes={searchableAttributes}
              selectedData={this.props.selectedData}
              handleSelectData={this.props.handleSelectData}
              data={data}
            /> */}
          </div>
        </div>
      </>
    );
  }
}

export default AssignTab;

// export default compose(
//   withPrepareData(tableConfig),
//   withSelectLogic
// )(AssignTab);