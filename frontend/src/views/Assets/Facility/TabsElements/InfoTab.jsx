import React, { Component } from 'react';
import DescriptionTable from '../../../../components/Descriptions/DescriptionTable';
import { itemsMatrixGeneral, itemsMatrixLocation } from '../utils/descriptionMatrix';

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