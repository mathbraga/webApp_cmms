import React from 'react';

import PaneTitle from '../../../components/TabPanes/PaneTitle';
import PaneTextContent from '../../../components/TabPanes/PaneTextContent';
import { itemsMatrixGeneral, itemsMatrixDate } from '../utils/descriptionMatrix';


function InfoTab({ data }) {
  
  return (
    <div className="tabpane-container">
      <PaneTitle 
        title={'Detalhes do Serviço'}
      />
      <div className="tabpane__content">
        <PaneTextContent 
          numColumns='2' 
          itemsMatrix={itemsMatrixGeneral(data)}
        />
      </div>
      <PaneTitle 
        title={'Prazos e Datas'}
      />
      <div className="tabpane__content">
        <PaneTextContent 
          numColumns='2' 
          itemsMatrix={itemsMatrixDate(data)}
        />
      </div>
    </div>
  );
}

export default InfoTab;