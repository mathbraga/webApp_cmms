import React, { Component } from 'react';
import DescriptionTable from '../../../components/Descriptions/DescriptionTable';
import { itemsMatrixGeneral, itemsMatrixManufacturer, itemsMatrixParent } from '../utils/descriptionMatrix';

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
          title={'Fabricante'}
          numColumns={2}
          itemsMatrix={itemsMatrixManufacturer(data)}
        />
        <DescriptionTable
          title={'Ativo Pai'}
          numColumns={2}
          itemsMatrix={itemsMatrixParent(data)}
        />
      </>
    );
  }
}

export default InfoTab;