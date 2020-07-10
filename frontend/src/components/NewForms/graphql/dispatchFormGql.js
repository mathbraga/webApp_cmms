import gql from 'graphql-tag';

export const ALL_TEAMS_QUERY = gql`
  query TeamsQuery($taskId: Int!) {
    allTaskData(condition: {taskId: $taskId}) {
      nodes {
        sendOptions
      }
    }
  }
`;

export const SEND_TASK = gql`
  mutation SendTaskMutation($taskId: Int!, $personId: Int!, $teamId: Int!, $nextTeamId: Int!, $note: String) {
    sendTask(input: {
      event: {
        taskId: $taskId,
        personId: $personId,
        teamId: $teamId,
        nextTeamId: $nextTeamId,
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
        createdAt
        taskStatusText
        teamName
        nextTeamName
        events
      }
    }
  }
 `;