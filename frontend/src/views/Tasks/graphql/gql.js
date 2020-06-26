import gql from 'graphql-tag';

export const TASKS_QUERY = gql`
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