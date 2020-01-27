import gql from 'graphql-tag';

const fetchGQL = gql`
  query ($taskId: Int!) {
    queryResponse: allTaskData(condition: {taskId: $taskId}) {
      nodes {
        taskId
        assets
        contract
        contractId
        createdAt
        dateEnd
        dateLimit
        dateStart
        files
        description
        personId
        place
        progress
        projectId
        requestDepartment
        requestName
        requestPhone
        requestEmail
        supplies
        taskCategoryId
        taskCategoryText
        taskPriorityId
        taskPriorityText
        taskStatusId
        taskStatusText
        teamId
        title
        updatedAt
      }
    }
  }
`;

const fetchVariables = {};

export { fetchGQL, fetchVariables };