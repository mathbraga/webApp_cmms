import React, { Component } from 'react';
import withDataFetching from '../../../components/DataFetch';
import withAccessToSession from '../../Authentication';
import { fetchGQL } from './utils/dataFetchParameters';
import withGraphQLVariables from './withGraphQLVariables';
import { compose } from 'redux';
import ItemView from '../../../components/ItemView/ItemView';
import tabsGenerator from './tabsGenerator';

const image = require("../../../assets/img/test/facilities_picture.jpg");
const imageStatus = 'Trânsito Livre';

class Facility extends Component {
  render() {
    const { data, ...rest } = this.props;
    const finalData = data.queryResponse.nodes[0];
    const assetsTabData = data.assetChildren.nodes[0];

    const descriptionItems = [
      { title: 'Edifício / Área', description: finalData.name, boldTitle: true },
      { title: 'Código', description: finalData.assetSf, boldTitle: false },
      { title: 'Departamento(s)', description: finalData.department, boldTitle: true },
      { title: 'Área', description: finalData.area, boldTitle: true },
    ];
    return (
      <ItemView
        data={finalData}
        image={image}
        imageStatus={imageStatus}
        descriptionItems={descriptionItems}
        tabs={tabsGenerator(data)}
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