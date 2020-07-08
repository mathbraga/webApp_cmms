import gql from 'graphql-tag';

export const MOVE_OPTIONS_QUERY = gql`
  query MoveOptionsQuery {
    allTaskData {
      nodes {
        moveOptions
      }
    }
  }
`;

export const MOVE_TASK = gql`
  mutation SendTaskMutation($taskId: Int!, $teamId: Int!, $taskStatusId: Int!, $note: String) {
    sendTask(input: {
      event: {
        taskId: $taskId,
        teamId: $teamId,
        taskStatusId: $taskStatusId,
        note: $note
      }
    }) {
      id
    }
  }
`;

export const TASK_EVENTS_QUERY = gql`
  query TaskQuery($taskId: Int!) {
    allTaskData(condition: {taskId: $taskId}) {
      nodes {
        taskId
      }
    }
  }
 `;