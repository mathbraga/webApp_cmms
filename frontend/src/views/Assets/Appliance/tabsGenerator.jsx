import React from 'react';
import InfoTab from './TabsElements/InfoTab';
import LocationTab from './TabsElements/LocationTab';
import MaintenanceTab from './TabsElements/MaintenanceTab';
import AssetTab from './TabsElements/AssetTab';
import WarrantyTab from './TabsElements/WarrantyTab';
import FilesTab from './TabsElements/FilesTab';
import LogTab from './TabsElements/LogTab';

export default function tabsGenerator(data) {
  return (
    [
      { id: 'info', title: 'Informações Gerais', element: <InfoTab data={data} /> },
      { id: 'location', title: 'Localização', element: <LocationTab data={data} /> },
      { id: 'maintenance', title: 'Manutenção', element: <MaintenanceTab data={data} /> },
      { id: 'warranty', title: 'Garantia', element: <WarrantyTab data={data} /> },
      { id: 'asset', title: 'Ativos', element: <AssetTab data={data} /> },
      { id: 'files', title: 'Arquivos', element: <FilesTab data={data} /> },
      { id: 'log', title: 'Histórico', element: <LogTab data={data} /> },
    ]
  );
}
