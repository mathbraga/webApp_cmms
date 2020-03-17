import React, { Component } from 'react';
import DescriptionTable from '../../../components/Descriptions/DescriptionTable';
import { itemsMatrixFiles } from '../utils/descriptionMatrix';

class FilesTab extends Component {
  render() {
    const { data } = this.props;
    return (
      <>
        <DescriptionTable
          title={'Dados sobre Arquivos'}
          numColumns={2}
          itemsMatrix={itemsMatrixFiles(data)}
        />
        <DescriptionTable
          title={'Lista de Arquivos'}
        />
      </>
    );
  }
}

export default FilesTab;