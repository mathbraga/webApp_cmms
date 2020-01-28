import React, { Component } from 'react';
import DescriptionTable from '../../../../components/Descriptions/DescriptionTable';
import { itemsMatrixGeneral } from '../utils/descriptionMatrix';
class InfoTab extends Component {
  render() {
    const { data } = this.props;
    return (
      <>
        <DescriptionTable
          title={'Especificações Técnicas'}
          numColumns={2}
          itemsMatrix={itemsMatrixGeneral(data)}
        />
      </>
    );
  }
}

export default InfoTab;