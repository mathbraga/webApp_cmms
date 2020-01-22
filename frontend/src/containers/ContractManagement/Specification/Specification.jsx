import React, { Component } from 'react';
import withDataFetching from '../../DataFetchContainer';
import withAccessToSession from '../../Authentication';
import { fetchGQL } from './utils/dataFetchParameters';
import withGraphQLVariables from './withGraphQLVariables';
import { compose } from 'redux';
import ItemView from '../../ItemView/ItemView';
import tabsGenerator from './tabsGenerator';

const image = require("../../../assets/img/test/equipment_picture.jpg");
const imageStatus = 'Em andamento';

class Task extends Component {
  render() {
    console.log("Props: ", this.props);
    const { data, ...rest } = this.props;
    const treatedData = data;
    const descriptionItems = [
      { title: 'Serviço', description: treatedData.orderByOrderId.title, boldTitle: true },
      { title: 'Ordem de Serviço nº', description: treatedData.orderByOrderId.orderId.toString().padStart(4, "0"), boldTitle: false },
      { title: 'Local', description: treatedData.orderByOrderId.place, boldTitle: false },
      { title: 'Categoria', description: treatedData.orderByOrderId.category, boldTitle: false },
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
)(Task);