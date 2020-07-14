import React, { useState, useContext, useEffect } from 'react';

import DispatchForm from '../../../components/NewForms/DispatchForm';
import StatusForm from '../../../components/NewForms/StatusForm';
import ReceiveForm from '../../../components/NewForms/ReceiveForm';
import PaneTitle from '../../../components/TabPanes/PaneTitle';
import PaneTextContent from '../../../components/TabPanes/PaneTextContent';
import { currentStateInfo, dispatchLogInfo } from '../utils/dispatchTab/descriptionMatrix';
import { UserContext } from '../../../context/UserProvider';
import './Tabs.css';

import sortList from '../../../components/Tables/TableWithSorting/sortList';

import AnimateHeight from 'react-animate-height';
import LogTable from '../utils/dispatchTab/LogTable';
import { useQuery, useMutation } from '@apollo/react-hooks';

import { CANCEL_SEND_TASK, TASK_EVENTS_QUERY } from '../../../components/NewForms/graphql/dispatchFormGql';

const NO_ACTIONS = 'noActions';
const NO_FORM = 'noForm';
const DISPATCH_FORM = 'dispatchForm';
const STATUS_FORM = 'statusForm';
const RECEIVE_FORM = 'receiveForm';
const NO_FORM_RECEIVE_TASK = 'noFormReceiveTask';
const NO_FORM_CANCEL_TASK = 'noFormCancelTask';

function DispatchTab({ data: { taskId, createdAt, taskStatusText, teamName, events, nextTeamId, teamId } }) {
  const [ openedForm, setOpenedForm ] = useState(NO_FORM);
  const [ logType, setLogType ] = useState('all');
  
  const { user, team } = useContext(UserContext);
  
  const [ cancelSendTask, { errorCancelSend } ] = useMutation(CANCEL_SEND_TASK, {
    variables: {
      taskId,
      personId: user && user.value,
      teamId: team &&  team.value,
    },
    onCompleted: () => {
      setOpenedForm(NO_FORM);
    },
    refetchQueries: [{ query: TASK_EVENTS_QUERY, variables: { taskId } }],
    awaitRefetchQueries: true,
    onError: (err) => { console.log(err); },
  });

  function handleLogTypeChange(event) {
    setLogType(event.target.value);
  }
  
  function handleCancelSendTask() {
    cancelSendTask();
  }
  
  function toggleForm(form) {
    if (openedForm === form) {
      setOpenedForm(NO_FORM);
    } else {
      setOpenedForm(form);
    }
  }

  if (openedForm === NO_FORM) {
    if (events.slice(-1)[0].eventName === 'send' && team && team.value === nextTeamId) {
      setOpenedForm(NO_FORM_RECEIVE_TASK);
    } else if (events.slice(-1)[0].eventName === 'send' && team && team.value === teamId) {
      setOpenedForm(NO_FORM_CANCEL_TASK);
    } else if (nextTeamId) {
      setOpenedForm(NO_ACTIONS);
    }
  }
  

  const actionButtons = {
    statusForm: [
      {name: 'Cancelar', color: 'danger', onClick: () => {toggleForm(STATUS_FORM)}}
    ],
    dispatchForm: [
      {name: 'Cancelar', color: 'danger', onClick: () => {toggleForm(DISPATCH_FORM)}}
    ],
    noForm: [
      {name: 'Tramitar Tarefa', color: 'primary', onClick: () => {toggleForm(DISPATCH_FORM)}},
      {name: 'Alterar Status', color: 'success', onClick: () => {toggleForm(STATUS_FORM)}}
    ],
    noFormReceiveTask: [
      {name: 'Receber Tarefa', color: 'success', onClick: () => {toggleForm(RECEIVE_FORM)}},
    ],
    noFormCancelTask: [
      {name: 'Cancelar Tramitação', color: 'danger', onClick: handleCancelSendTask}
    ],
    receiveForm: [
      {name: 'Voltar', color: 'danger', onClick: () => {toggleForm(RECEIVE_FORM)}}
    ],
  };
  
  const titlesPane = {
    noActions: 'Situação Atual',
    statusForm: 'Alterar Status',
    dispatchForm: 'Tramitar Tarefa',
    receiveForm: 'Receber Tramitação',
    noForm: 'Situação Atual',
    noFormReceiveTask: 'Situação Atual',
    noFormCancelTask: 'Situação Atual',
    receiveTaskForm: 'Receber Tarefa',
  }
  
  const formOpen = {
    noAction: false,
    statusForm: true,
    dispatchForm: true,
    receiveForm: true,
    noForm: false,
    noFormReceiveTask: false,
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
        height={openedForm === DISPATCH_FORM ? 'auto' : 0}
        >
          <div className="tabpane__content">
            <DispatchForm 
              visible={true}
              toggleForm={() => {toggleForm(DISPATCH_FORM)}}
              taskId={taskId}
            />
          </div>
        </AnimateHeight>
        <AnimateHeight 
          duration={300}
          height={openedForm === STATUS_FORM ? 'auto' : 0}
        >
          <div className="tabpane__content">
            <StatusForm 
              visible={true}
              toggleForm={() => {toggleForm(STATUS_FORM)}}
              taskId={taskId}
            />
          </div>
        </AnimateHeight>
        <AnimateHeight 
          duration={300}
          height={openedForm === RECEIVE_FORM ? 'auto' : 0}
        >
          <div className="tabpane__content">
            <ReceiveForm 
              visible={true}
              toggleForm={() => {toggleForm(RECEIVE_FORM)}}
              setOpenedForm={setOpenedForm}
              taskId={taskId}
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