import React from 'react';
import InfoTab from './TabsElements/InfoTab';
import ContractsTab from './TabsElements/ContractsTab';
import TasksTab from './TabsElements/TasksTab';
import LogTab from './TabsElements/LogTab';

export default function tabsGenerator(data) {
  return (
    [
      { id: 'info', title: 'Informações Gerais', element: <InfoTab data={data} /> },
      { id: 'contracts', title: 'Contratos', element: <ContractsTab data={data} /> },
      { id: 'tasks', title: 'Ordens de Serviço', element: <TasksTab data={data} /> },
      { id: 'log', title: 'Histórico', element: <LogTab data={data} /> },
    ]
  );
}
