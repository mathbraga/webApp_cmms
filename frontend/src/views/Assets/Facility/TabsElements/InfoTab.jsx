import React, { Component } from 'react';
import DescriptionTable from '../../../../components/Descriptions/DescriptionTable';

function itemsMatrixGeneral(data) {
  return (
    [
      [{ id: 'facility', title: 'Nome do Edifício ou Área', description: data.name, span: 1 }, { id: 'department', title: 'Departamento (s)', description: data.department, line: 1, span: 1 },],
      [{ id: 'code', title: 'Código', description: data.assetSf, span: 1 }],
      [{ id: 'description', title: 'Descrição do Edifício', description: data.description, span: 2 }]
    ]
  );
}

function itemsMatrixLocation(data) {
  return (
    [
      [
        { id: 'facilityParent', title: 'Ativo Pai', description: data.superior, span: 1 },
        { id: 'latitude', title: 'Latitude do Local', description: data.latitude, line: 1, span: 1 },
      ],
      [
        { id: 'longitude', title: 'Área', description: data.longitude, span: 1 },
        { id: 'area', title: 'Longitude do Local', description: data.area, line: 1, span: 1 },
      ],
    ]
  );
}

class InfoTab extends Component {
  render() {
    const { data } = this.props;
    return (
      <>
        <DescriptionTable
          title={'Dados Gerais'}
          numColumns={2}
          itemsMatrix={itemsMatrixGeneral(data)}
        />
        <DescriptionTable
          title={'Localização'}
          numColumns={2}
          itemsMatrix={itemsMatrixLocation(data)}
        />
      </>
    );
  }
}

export default InfoTab;