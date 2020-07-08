import gql from 'graphql-tag';

export const ALL_TEAMS_QUERY = gql`
  query TeamsQuery {
    allTeamData {
      nodes {
        teamId
        name
      }
    }
  }
`;

export const SEND_TASK = gql`
  mutation SendTaskMutation($taskId: Int!, $teamId: Int!, $note: String) {
    sendTask(input: {
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

export const TASK_TEAMS_QUERY = gql`
  query TaskQuery($taskId: Int!) {
    allTaskData(condition: {taskId: $taskId}) {
      nodes {
        taskId
        events
        teamId
        teamName
      }
    }
  }
 `;