import React, { Component } from 'react';

import DispatchForm from '../../../components/NewForms/DispatchForm'
import StatusForm from '../../../components/NewForms/StatusForm'
import PaneTitle from '../../../components/TabPanes/PaneTitle'
import PaneTextContent from '../../../components/TabPanes/PaneTextContent';
import { itemsMatrixAssetsHierachy, itemsMatrixLog } from '../utils/dispatchTab/descriptionMatrix';
import './Tabs.css'

import fakeData from '../utils/dispatchTab/fakeData';

import sortList from '../../../components/Tables/TableWithSorting/sortList'

import AnimateHeight from 'react-animate-height';
import LogTable from '../utils/dispatchTab/LogTable';

class AssignTab extends Component {
  constructor(props) {
    super(props);
    this.state = {
      dispatchFormOpen: false,
      statusFormOpen: false,
      logType: 'all',
    };
    this.toggleDispatchForm = this.toggleDispatchForm.bind(this);
    this.toggleStatusForm = this.toggleStatusForm.bind(this);
    this.handleLogTypeChange = this.handleLogTypeChange.bind(this);
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

  handleLogTypeChange(event) {
    this.setState({
      logType: event.target.value,
    });
  }

  render() {
    const data = fakeData;
    //this.props.data.assets;
    const { dispatchFormOpen, statusFormOpen, logType } = this.state;

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

    const filteredData = logType === 'all' ? data : (data.filter(item => (logType === 'status' ? (item.event === 'move' || item.event === 'insert') : (item.event !== 'move'))));
    const sortedData = sortList(filteredData, 'time', true, false);

    console.log("Type", logType);

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
            <PaneTextContent 
              numColumns='2' 
              itemsMatrix={itemsMatrixLog(sortedData.length, this.handleLogTypeChange)}
            />
          </div>
          <div className="tabpane__content__table">
            <LogTable 
              data={sortedData}
            />
          </div>
        </div>
      </>
    );
  }
}

export default AssignTab;