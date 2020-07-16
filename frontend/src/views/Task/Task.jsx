import React, { Component } from 'react';
import { compose } from 'redux';
import ItemView from '../../components/ItemView/ItemView';
import tabsGenerator from './tabsGenerator';
import moment from 'moment';
import { withProps, withGraphQL, withQuery } from '../../hocs';
import paths from '../../paths';

import { useQuery } from '@apollo/react-hooks';

import { TASK_QUERY } from './graphql/gql';

// Image by <a href="https://pixabay.com/users/OpenClipart-Vectors-30363/?utm_source=link-attribution&amp;utm_medium=referral&amp;utm_campaign=image&amp;utm_content=1295319">OpenClipart-Vectors</a> from <a href="https://pixabay.com/?utm_source=link-attribution&amp;utm_medium=referral&amp;utm_campaign=image&amp;utm_content=1295319">Pixabay</a>
const image = require("../../assets/img/entities/task.png");

const descriptionItems = [
  { title: 'Serviço', description: "", boldTitle: true },
  { title: 'Prazo', description: "", boldTitle: false },
  { title: 'Local', description: "", boldTitle: false },
  { title: 'Descrição', description: "", boldTitle: false },
];

function Task(props) {
  const taskId = Number(props.match.params.id)
  
  const { loading, data: { allTaskData: { nodes: [data] = [] } = {} } = {} } = useQuery(TASK_QUERY, {
    variables: { taskId }
   });
   
   const imageStatus = data && data.taskStatusText;
   
   if (!loading) {
    descriptionItems[0].description = data.title;
    descriptionItems[1].description = moment(data.dateLimit).format("DD-MM-YYYY");
    descriptionItems[2].description = data.place;
    descriptionItems[3].description = data.description;
   }

  return (
    loading ? (
      <div>Loading</div>
    ) : (
      <ItemView
        sectionName={`Tarefa nº ${taskId.toString().padStart(6, "0")}`}
        sectionDescription={'Informações detalhadas da tarefa'}
        data={data}
        image={image}
        imageStatus={imageStatus}
        descriptionItems={descriptionItems}
        tabs={tabsGenerator(data)}
        buttonPath={paths.task.toUpdate + taskId.toString()}
        buttonName={"Editar"}
        {...props}
      />
    )
  );
}

export default Task;


