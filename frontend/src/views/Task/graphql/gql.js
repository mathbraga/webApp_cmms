import gql from 'graphql-tag';

export const TASK_QUERY = gql`
  query TaskQuery($taskId: ID!) {
    allTaskData(condition: {taskId: $taskId}) {
      nodes {
        taskId
        contracts
        createdAt
        createdBy
        dateEnd
        dateLimit
        dateStart
        description
        events
        files
        messages
        moveOptions
        nextTeamId
        nextTeamName
        place
        progress
        project
        request
        supplies
        sendOptions
        taskCategoryText
        taskPriorityText
        taskStatusId
        taskStatusText
        teamId
        teamName
        updatedBy
        updatedAt
        title
        assets
      }
    }
  }
`;