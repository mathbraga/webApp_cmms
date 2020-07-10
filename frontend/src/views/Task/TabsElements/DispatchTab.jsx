import React, { Component } from 'react';

import DispatchForm from '../../../components/NewForms/DispatchForm'
import StatusForm from '../../../components/NewForms/StatusForm'
import PaneTitle from '../../../components/TabPanes/PaneTitle'
import PaneTextContent from '../../../components/TabPanes/PaneTextContent';
import { currentStateInfo, dispatchLogInfo } from '../utils/dispatchTab/descriptionMatrix';
import './Tabs.css'

import sortList from '../../../components/Tables/TableWithSorting/sortList'

import AnimateHeight from 'react-animate-height';
import LogTable from '../utils/dispatchTab/LogTable';

class DispatchTab extends Component {
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
    const { taskId, createdAt, taskStatusText, teamName, events, nextTeamId } = this.props.data;
    const { dispatchFormOpen, statusFormOpen, logType } = this.state;
    
    console.log("Data Status: ", this.props.data);

    const actionButtons = {
      statusFormOpen: [
        {name: 'Cancelar', color: 'danger', onClick: this.toggleStatusForm}
      ],
      dispatchFormOpen: [
        {name: 'Cancelar', color: 'danger', onClick: this.toggleDispatchForm}
      ],
      noFormOpen: [
        {name: 'Tramitar Tarefa', color: 'primary', onClick: this.toggleDispatchForm},
        {name: 'Alterar Status', color: 'success', onClick: this.toggleStatusForm}
      ],
      receiveTask: [
        {name: 'Receber Tarefa', color: 'success', onClick: this.toggleDispatchForm},
        {name: 'Cancelar Tramitação', color: 'danger', onClick: this.toggleStatusForm}
      ],
    };
    const openedForm = dispatchFormOpen ? 'dispatchFormOpen' : (statusFormOpen ? 'statusFormOpen' : 'noFormOpen');
    const heightDispatch = openedForm === 'dispatchFormOpen' ? 'auto' : 0;
    const heightStatus = openedForm === 'statusFormOpen' ? 'auto' : 0;

    const filteredData = logType === 'all' ? events : (events.filter(item => (logType === 'status' ? (item.event === 'move' || item.event === 'insert') : (item.event !== 'move'))));
    const sortedData = sortList(filteredData, 'time', true, false);

    return (
      <>
        <div className="tabpane-container">
          <PaneTitle 
            actionButtons={nextTeamId ? (actionButtons["receiveTask"]) : actionButtons[openedForm]}
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
                taskId={taskId}
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
              itemsMatrix={currentStateInfo({createdAt, taskStatusText, teamName, events})}
            />
          </div>
          <PaneTitle 
            title={'Histórico'}
          />
          <div className="tabpane__content">
            <PaneTextContent 
              numColumns='2' 
              itemsMatrix={dispatchLogInfo(sortedData.length, this.handleLogTypeChange)}
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

export default DispatchTab;