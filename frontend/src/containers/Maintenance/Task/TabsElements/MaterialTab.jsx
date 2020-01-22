import React, { Component } from 'react';
import DescriptionTable from '../../../../components/Description/DescriptionTable';
import { itemsMatrixMaterial } from '../utils/descriptionMatrix';
import tableConfig from '../utils/tableConfig';
import { customFilters, filterAttributes } from '../utils/filterParameters';
import searchableAttributes from '../utils/searchParameters';
import CardWithTable from '../../../TableContainer/CardWithTable';
import './Tabs.css';

class MaterialTab extends Component {
  state = {}
  render() {
    const data = this.props.data.allOrderSuppliesDetails.nodes;
    console.log("Material: ", data);
    return (
      <>
        <DescriptionTable
          title={'Lista de Materiais e Serviços'}
          numColumns={2}
          itemsMatrix={itemsMatrixMaterial(data)}
        />
        <CardWithTable
          tableConfig={tableConfig}
          customFilters={customFilters}
          filterAttributes={filterAttributes}
          searchableAttributes={searchableAttributes}
          hasAssetCard={false}
          data={data}
        />
      </>
    );
  }
}

export default MaterialTab;