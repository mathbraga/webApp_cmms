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
    const treatedData = data;
    const descriptionItems = [
      { title: 'Serviço / Material', description: treatedData.specBySpecId.name, boldTitle: true },
      { title: 'Código', description: treatedData.specBySpecId.specSf, boldTitle: false },
      { title: 'Versão', description: treatedData.specBySpecId.version, boldTitle: false },
      { title: 'Disponibilidade', description: treatedData.allBalances.nodes.reduce((acc, item) => (Number(item.available) + Number(acc)), 0), boldTitle: false },
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
)(Specification);