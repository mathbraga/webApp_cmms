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
      { id: 'info', title: 'Informações Gerais', element: <InfoTab data={data || []} /> },
      { id: 'location', title: 'Planta Arquitetônica', element: <LocationTab data={data || []} /> },
      { id: 'maintenance', title: 'Manutenções', element: <MaintenanceTab data={data || []} /> },
      { id: 'asset', title: 'Ativos', element: <AssetTab data={data || []} /> },
      { id: 'files', title: 'Arquivos', element: <FilesTab data={data || []} /> },
      { id: 'log', title: 'Histórico', element: <LogTab data={data || []} /> },
    ]
  );
}
