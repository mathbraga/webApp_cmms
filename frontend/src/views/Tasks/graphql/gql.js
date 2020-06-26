import gql from 'graphql-tag';

export const TASKS_GQL = gql`
  query TasksQuery {
    allTaskData {
      nodes {
        taskId
        title
        taskCategoryText
        taskStatusText
        dateLimit
        place
      }
    }
  }
`;