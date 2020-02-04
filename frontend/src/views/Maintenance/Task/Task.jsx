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

class Task extends Component {
  render() {
    const { data, customGraphQLVariables, ...rest } = this.props;
    const finalData = data.queryResponse.nodes[0];
    const descriptionItems = [
      { title: 'Serviço', description: finalData.title, boldTitle: true },
      { title: 'Ordem de Serviço nº', description: finalData.taskId.toString().padStart(4, "0"), boldTitle: false },
      { title: 'Local', description: finalData.place, boldTitle: false },
      { title: 'Categoria', description: finalData.taskCategoryText, boldTitle: false },
    ];
    return (
      <ItemView
        data={finalData}
        image={image}
        imageStatus={imageStatus}
        buttonName={"Editar"}
        buttonPath={"/manutencao/os/edit/" + customGraphQLVariables.taskId}
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
)(Task);