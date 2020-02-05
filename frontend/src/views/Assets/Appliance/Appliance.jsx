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
    const { data, customGraphQLVariables, ...rest } = this.props;
    const finalData = data.queryResponse.nodes[0];
    const descriptionItems = [
      { title: 'Equipamento / Sistema', description: finalData.name, boldTitle: true },
      { title: 'Código', description: finalData.assetSf, boldTitle: false },
      { title: 'Modelo', description: finalData.model, boldTitle: false },
      { title: 'Fabricante', description: finalData.manufacturer, boldTitle: false },
    ];
    return (
      <ItemView
        data={finalData}
        image={image}
        imageStatus={imageStatus}
        buttonName={"Editar"}
        buttonPath={"/ativos/equipamento/edit/" + customGraphQLVariables.assetId}
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
)(Appliance);