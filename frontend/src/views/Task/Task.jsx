import React, { Component } from 'react';
import { compose } from 'redux';
import ItemView from '../../components/ItemView/ItemView';
import tabsGenerator from './tabsGenerator';
import props from './props';
import { withProps, withGraphQL, withQuery } from '../../hocs';
import paths from '../../paths';

import { useQuery } from '@apollo/react-hooks';

import { TASKS_QUERY } from './graphql/gql';

// Image by <a href="https://pixabay.com/users/OpenClipart-Vectors-30363/?utm_source=link-attribution&amp;utm_medium=referral&amp;utm_campaign=image&amp;utm_content=1295319">OpenClipart-Vectors</a> from <a href="https://pixabay.com/?utm_source=link-attribution&amp;utm_medium=referral&amp;utm_campaign=image&amp;utm_content=1295319">Pixabay</a>
const image = require("../../assets/img/entities/task.png");
const imageStatus = 'Em andamento';

class Task extends Component {
  render() {
    const { data, graphQLVariables, ...rest } = this.props;
    const finalData = data.queryResponse.nodes[0];
    const descriptionItems = [
      { title: 'Serviço', description: finalData.title, boldTitle: true },
      { title: 'O.S. nº', description: finalData.taskId.toString().padStart(4, "0"), boldTitle: false },
      { title: 'Local', description: finalData.place, boldTitle: false },
      { title: 'Categoria', description: finalData.taskCategoryText, boldTitle: false },
    ];
    return (
      <ItemView
        sectionName={'Tarefa'}
        sectionDescription={'Ficha descritiva de uma tarefa'}
        data={finalData}
        image={image}
        imageStatus={imageStatus}
        descriptionItems={descriptionItems}
        tabs={tabsGenerator(finalData)}
        buttonPath={paths.task.toUpdate + graphQLVariables.id.toString()}
        buttonName={"Editar"}
        {...rest}
      />
    );
  }
}

export default Task;