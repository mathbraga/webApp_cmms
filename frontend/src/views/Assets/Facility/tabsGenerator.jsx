import React, { Component } from 'react';
import InfoTab from './TabsElements/InfoTab';
import LocationTab from './TabsElements/LocationTab';
import MaintenanceTab from './TabsElements/MaintenanceTab';
import AssetTab from './TabsElements/AssetTab';
import FilesTab from './TabsElements/FilesTab';
import LogTab from './TabsElements/LogTab';

export default function tabsGenerator(data) {
  return (
    [
      { id: 'info', title: 'Informações Gerais', element: <InfoTab data={data.queryResponse.nodes[0]} /> },
      { id: 'location', title: 'Planta Arquitetônica', element: <LocationTab data={data.queryResponse.nodes[0]} /> },
      { id: 'maintenance', title: 'Manutenções', element: <MaintenanceTab data={data.queryResponse.nodes[0]} /> },
      { id: 'asset', title: 'Ativos', element: <AssetTab data={data.assetChildren.nodes[0] ? data.assetChildren.nodes[0].assets : []} /> },
      { id: 'files', title: 'Arquivos', element: <FilesTab data={data.queryResponse.nodes[0]} /> },
      { id: 'log', title: 'Histórico', element: <LogTab data={data.queryResponse.nodes[0]} /> },
    ]
  );
}
