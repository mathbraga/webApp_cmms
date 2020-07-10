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

const NO_ACTIONS = 'noActions';
const NO_FORM = 'noForm';
const DISPATCH_FORM = 'dispatchForm';
const STATUS_FORM = 'statusForm';
const RECEIVE_FORM = 'receiveForm';
const NO_FORM_RECEIVE_TASK = 'noFormReceiveTask';

function DispatchTab({ data: { taskId, createdAt, taskStatusText, teamName, events, nextTeamId } }) {
  const [openedForm, setOpenedForm] = useState(NO_FORM);
  const [ logType, setLogType ] = useState('all');
  
  const { user, team } = useContext(UserContext);

  function handleLogTypeChange(event) {
    setLogType(event.target.value);
  }
  
  function toggleStatusForm() {
    if (openedForm === 'statusForm') {
      setOpenedForm(NO_FORM);
    } else {
      setOpenedForm(STATUS_FORM);
    }
  }
  
  function toggleDispatchForm() {
    if (openedForm === 'dispatchForm') {
      setOpenedForm(NO_FORM);
    } else {
      setOpenedForm(DISPATCH_FORM);
    }
  }
  

  if(openedForm === NO_FORM && team && team.value === nextTeamId) {
    setOpenedForm(NO_FORM_RECEIVE_TASK);
  } else if(openedForm === NO_FORM && nextTeamId) {
    setOpenedForm(NO_ACTIONS);
  }

  const actionButtons = {
    statusForm: [
      {name: 'Cancelar', color: 'danger', onClick: toggleStatusForm}
    ],
    dispatchForm: [
      {name: 'Cancelar', color: 'danger', onClick: toggleDispatchForm}
    ],
    noForm: [
      {name: 'Tramitar Tarefa', color: 'primary', onClick: toggleDispatchForm},
      {name: 'Alterar Status', color: 'success', onClick: toggleStatusForm}
    ],
    noFormReceiveTask: [
      {name: 'Receber Tarefa', color: 'success', onClick: toggleDispatchForm},
      {name: 'Cancelar Tramitação', color: 'danger', onClick: toggleStatusForm}
    ],
    receiveTaskForm: [
      {name: 'Receber Tarefa', color: 'success', onClick: toggleDispatchForm},
      {name: 'Cancelar Tramitação', color: 'danger', onClick: toggleStatusForm}
    ],
  };
  
  const titlesPane = {
    noActions: 'Situação Atual',
    statusForm: 'Alterar Status',
    dispatchForm: 'Tramitar Tarefa',
    noForm: 'Situação Atual',
    noFormReceiveTask: 'Situação Atual',
    receiveTaskForm: 'Receber Tarefa',
  }
  
  const formOpen = {
    noAction: false,
    statusForm: true,
    dispatchForm: true,
    noForm: false,
    noFormReceiveTask: false,
    receiveTaskForm: true,
  }

  const filteredData = logType === 'all' ? events : (events.filter(item => (logType === 'status' ? (item.event === 'move' || item.event === 'insert') : (item.event !== 'move'))));
  const sortedData = sortList(filteredData, 'time', true, false);

  return (
    <>
      <div className="tabpane-container">
        <PaneTitle 
          actionButtons={actionButtons[openedForm]}
          title={titlesPane[openedForm]}
        />
        <AnimateHeight 
        duration={300}
        height={openedForm === 'dispatchForm' ? 'auto' : 0}
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
          height={openedForm === 'StatusForm' ? 'auto' : 0}
        >
          <div className="tabpane__content">
            <StatusForm 
              visible={true}
              toggleForm={toggleStatusForm}
            />
          </div>
        </AnimateHeight>
        {formOpen[openedForm] && (
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