import React from 'react';
import DescriptionTable from '../../../components/Descriptions/DescriptionTable';
import { itemsMatrixGeneral, itemsMatrixDate } from '../utils/descriptionMatrix';


function InfoTab({ data }) {
  return (
    <>
      <DescriptionTable
        title={'Detalhes do Serviço'}
        numColumns={2}
        itemsMatrix={itemsMatrixGeneral(data)}
      />
      <DescriptionTable
        title={'Prazos e Datas'}
        numColumns={2}
        itemsMatrix={itemsMatrixDate(data)}
      />
    </>
  );
}

export default InfoTab;