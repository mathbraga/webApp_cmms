import React, { Component } from 'react';
import withDataFetching from '../../DataFetchContainer';
import withAccessToSession from '../../Authentication';
import { fetchGQL } from './utils/dataFetchParameters';
import withGraphQLVariables from './withGraphQLVariables';
import { compose } from 'redux';
import ItemView from '../../ItemView/ItemView';
import tabsGenerator from './tabsGenerator';

const image = require("../../../assets/img/test/facilities_picture.jpg");
const imageStatus = 'Trânsito Livre';

class Facility extends Component {
  render() {
    const { data, ...rest } = this.props;
    const treatedData = data.assetByAssetSf;
    const descriptionItems = [
      { title: 'Edifício / Área', description: treatedData.name, boldTitle: true },
      { title: 'Código', description: treatedData.assetSf, boldTitle: false },
      { title: 'Departamento(s)', description: treatedData.department, boldTitle: true },
      { title: 'Área', description: treatedData.area, boldTitle: true },
    ];
    return (
      <ItemView
        data={treatedData}
        image={image}
        imageStatus={imageStatus}
        descriptionItems={descriptionItems}
        tabs={tabsGenerator(treatedData)}
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