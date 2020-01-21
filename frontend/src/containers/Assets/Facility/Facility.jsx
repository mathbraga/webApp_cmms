import React, { Component } from 'react';
import withDataFetching from '../../DataFetchContainer';
import withAccessToSession from '../../Authentication';
import { fetchGQL } from './utils/dataFetchParameters';
import withGraphQLVariables from './withGraphQLVariables';
import { compose } from 'redux';
import ItemView from '../../ItemView/ItemView';

class Facility extends Component {
  render() {
    const { data, ...rest } = this.props
    const treatedData = data.assetByAssetSf;
    const image = require("../../../assets/img/test/facilities_picture.jpg");
    const imageStatus = 'Trânsito Livre'
    const descriptionItems = [
      { title: 'Edifício / Área', description: treatedData.name, boldTitle: true },
      { title: 'Código', description: treatedData.assetSf, boldTitle: false },
      { title: 'Departamento(s)', description: treatedData.department, boldTitle: true },
      { title: 'Área', description: treatedData.area, boldTitle: true },
    ];
    const tabs = [
      { id: 'info', title: 'Informação', element: <div>Hi1</div> },
      { id: 'info2', title: 'Preço', element: <div>Hi2</div> },
      { id: 'info3', title: 'Custo', element: <div>Hi3</div> },
      { id: 'info4', title: 'Lucro', element: <div>Hi4</div> },
    ];
    return (
      <ItemView
        data={treatedData}
        image={image}
        imageStatus={imageStatus}
        descriptionItems={descriptionItems}
        tabs={tabs}
        {...rest}
      />
    );
  }
}

export default compose(
  withGraphQLVariables,
  withAccessToSession,
  withDataFetching(fetchGQL, false)
)(Facility);