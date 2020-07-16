import gql from 'graphql-tag';

export const INSERT_TASK_MESSAGE = gql`
  mutation myMutation($taskId: Int!, $teamId: Int!, $note: String!) {
    insertTaskNote(input: {
      event: {
        taskId: $taskId,
        teamId: $teamId,
        note: $note
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
        events
      }
    }
  }
 `;