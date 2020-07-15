import gql from 'graphql-tag';

export const INSERT_TASK_MESSAGE = gql`
  mutation myMutation($taskId: Int!, $message: String!) {
    insertTaskMessage(input: {
      message: {
        taskId: $taskId,
        message: $message
      }
    }) {
      id
    }
  }
`;

export const TASK_MESSAGES = gql`
  query myQuery($taskId: Int!) {
    allTaskData(condition: {taskId: $taskId}) {
      nodes {
        taskId
        messages
      }
    }
  }
 `;