import React from 'react';
import InfoTab from './TabsElements/InfoTab';
import MaterialTab from './TabsElements/MaterialTab';
import AssignTab from './TabsElements/AssignTab';
import AssetTab from './TabsElements/AssetTab';
import ClientTab from './TabsElements/ClientTab';
import FilesTab from './TabsElements/FilesTab';

export default function tabsGenerator(data) {
  return (
    [
      { id: 'info', title: 'Informações', element: <InfoTab data={data} /> },
      { id: 'resources', title: 'Suprimentos', element: <MaterialTab data={data} /> },
      { id: 'assets', title: 'Ativos', element: <AssetTab data={data} /> },
      { id: 'assignTo', title: 'Status / Tramitações', element: <AssignTab data={data} /> },
      { id: 'client', title: 'Mensagens', element: <ClientTab data={data} /> },
      { id: 'files', title: 'Arquivos', element: <FilesTab data={data} /> },
    ]
  );
}
