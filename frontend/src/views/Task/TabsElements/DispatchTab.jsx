import React, { useState, useContext } from 'react';

import DispatchForm from '../../../components/NewForms/DispatchForm'
import StatusForm from '../../../components/NewForms/StatusForm'
import PaneTitle from '../../../components/TabPanes/PaneTitle'
import PaneTextContent from '../../../components/TabPanes/PaneTextContent';
import { currentStateInfo, dispatchLogInfo } from '../utils/dispatchTab/descriptionMatrix';
import { UserContext } from '../../../context/UserProvider';
import './Tabs.css'

import sortList from '../../../components/Tables/TableWithSorting/sortList'

import AnimateHeight from 'react-animate-height';
import LogTable from '../utils/dispatchTab/LogTable';

function DispatchTab({ data: { taskId, createdAt, taskStatusText, teamName, events, nextTeamId } }) {
  const [ dispatchFormOpen, setDispatchFormOpen ] = useState(false);
  const [ statusFormOpen, setStatusFormOpen ] = useState(false);
  const [ logType, setLogType ] = useState('all');
  
  const { user, team } = useContext(UserContext);
  
  function toggleDispatchForm() {
    setDispatchFormOpen(!dispatchFormOpen);
    setStatusFormOpen(false);
  }

  function toggleStatusForm() {
    setStatusFormOpen(!statusFormOpen);
    setDispatchFormOpen(false);
  }

  function handleLogTypeChange(event) {
    setLogType(event.target.value);
  }

  const actionButtons = {
    statusFormOpen: [
      {name: 'Cancelar', color: 'danger', onClick: toggleStatusForm}
    ],
    dispatchFormOpen: [
      {name: 'Cancelar', color: 'danger', onClick: toggleDispatchForm}
    ],
    noFormOpen: [
      {name: 'Tramitar Tarefa', color: 'primary', onClick: toggleDispatchForm},
      {name: 'Alterar Status', color: 'success', onClick: toggleStatusForm}
    ],
    receiveTask: [
      {name: 'Receber Tarefa', color: 'success', onClick: toggleDispatchForm},
      {name: 'Cancelar Tramitação', color: 'danger', onClick: toggleStatusForm}
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
          actionButtons={nextTeamId ? (team && team.value == nextTeamId && actionButtons["receiveTask"]) : actionButtons[openedForm]}
          title={dispatchFormOpen ? 'Tramitar Tarefa' : (statusFormOpen ? 'Alterar Status' : 'Situação Atual')}
        />
        <AnimateHeight 
        duration={300}
        height={heightDispatch}
        >
          <div className="tabpane__content">
            <DispatchForm 
              visible={true}
              toggleForm={toggleDispatchForm}
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
              toggleForm={toggleStatusForm}
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
            itemsMatrix={dispatchLogInfo(sortedData.length, handleLogTypeChange)}
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

export default DispatchTab;