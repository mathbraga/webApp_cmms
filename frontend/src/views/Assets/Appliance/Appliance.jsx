import React, { Component } from 'react';
import { compose } from 'redux';
import PropTypes from 'prop-types';
import withDataFetching from '../../../components/DataFetch';
import withAccessToSession from '../../Authentication';
import withGraphQLVariables from './withGraphQLVariables';
import { fetchGQL } from './utils/dataFetchParameters';
import ItemView from '../../../components/ItemView/ItemView';
import tabsGenerator from './tabsGenerator';

// TO DO - These values will be passed as props
const image = require("../../../assets/img/test/equipment_picture.jpg");
const imageStatus = 'Funcionando';

class Appliance extends Component {
  render() {
    console.log("Props: ", this.props);
    const { data, ...rest } = this.props;
    const treatedData = data.assetByAssetSf;
    const descriptionItems = [
      { title: 'Equipamento / Sistema', description: treatedData.name, boldTitle: true },
      { title: 'Código', description: treatedData.assetSf, boldTitle: false },
      { title: 'Modelo', description: treatedData.model, boldTitle: false },
      { title: 'Fabricante', description: treatedData.manufacturer, boldTitle: false },
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
)(Appliance);