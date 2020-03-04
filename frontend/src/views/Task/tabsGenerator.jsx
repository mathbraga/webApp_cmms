import React from 'react';
import InfoTab from './TabsElements/InfoTab';
import MaterialTab from './TabsElements/MaterialTab';
import AssignTab from './TabsElements/AssignTab';
import AssetTab from './TabsElements/AssetTab';
import ClientTab from './TabsElements/ClientTab';
import FilesTab from './TabsElements/FilesTab';
import LogTab from './TabsElements/LogTab';

export default function tabsGenerator(data) {
  return (
    [
      { id: 'info', title: 'Informações Gerais', element: <InfoTab data={data} /> },
      { id: 'resources', title: 'Materiais e Serviços', element: <MaterialTab data={data} /> },
      { id: 'assets', title: 'Ativos', element: <AssetTab data={data} /> },
      { id: 'assignTo', title: 'Atribuido Para', element: <AssignTab data={data} /> },
      { id: 'client', title: 'Solicitante', element: <ClientTab data={data} /> },
      { id: 'files', title: 'Arquivos', element: <FilesTab data={data} /> },
      { id: 'log', title: 'Histórico', element: <LogTab data={data} /> },
    ]
  );
}
