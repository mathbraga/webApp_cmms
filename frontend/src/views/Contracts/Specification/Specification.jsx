import React, { Component } from 'react';
import withDataFetching from '../../../components/DataFetch';
import withAccessToSession from '../../Authentication';
import { fetchGQL } from './utils/dataFetchParameters';
import withGraphQLVariables from './withGraphQLVariables';
import { compose } from 'redux';
import ItemView from '../../../components/ItemView/ItemView';
import tabsGenerator from './tabsGenerator';

const image = require("../../../assets/img/test/equipment_picture.jpg");
const imageStatus = 'Em andamento';

class Specification extends Component {
  render() {
    console.log("Props: ", this.props);
    const { data, ...rest } = this.props;
    const finalData = data.queryResponse.nodes[0];
    const descriptionItems = [
      { title: 'Serviço / Material', description: finalData.name, boldTitle: true },
      { title: 'Código', description: finalData.specSf, boldTitle: false },
      { title: 'Versão', description: finalData.version, boldTitle: false },
      { title: 'Disponibilidade', description: finalData.supplies.reduce((acc, item) => (Number(item.qtyAvailable) + Number(acc)), 0), boldTitle: false },
    ];
    return (
      <ItemView
        data={finalData}
        image={image}
        imageStatus={imageStatus}
        descriptionItems={descriptionItems}
        tabs={tabsGenerator(finalData)}
        {...rest}
      />
    );
  }
}

export default compose(
  withGraphQLVariables,
  withAccessToSession,
  withDataFetching(fetchGQL, false)
)(Specification);