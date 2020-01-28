import React from 'react';
import InfoTab from './TabsElements/InfoTab';
import MaterialTab from './TabsElements/MaterialTab';
import DocumentTab from './TabsElements/DocumentTab';
import LogTab from './TabsElements/LogTab';

export default function tabsGenerator(data) {
  return (
    [
      { id: 'info', title: 'Informações Gerais', element: <InfoTab data={data} /> },
      { id: 'resources', title: 'Materiais e Serviços', element: <MaterialTab data={data} /> },
      { id: 'documents', title: 'Documentos Digitalizados', element: <DocumentTab data={data} /> },
      { id: 'log', title: 'Histórico', element: <LogTab data={data} /> },
    ]
  );
}
