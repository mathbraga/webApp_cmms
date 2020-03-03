import gql from 'graphql-tag';

const fetchGQLEdit = gql`
  query MyQuery {
    allTaskFormData {
      nodes {
        assetOptions
        categoryOptions
        contractOptions
        priorityOptions
        projectOptions
        statusOptions
        teamOptions
      }
    }
    allTaskData(condition: {taskId: $taskId}) {
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
        requestEmail
        requestName
        requestPhone
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

const fetchGQLNew = gql`
  query MyQuery {
    allTaskFormData {
      nodes {
        assetOptions
        categoryOptions
        contractOptions
        priorityOptions
        projectOptions
        statusOptions
        teamOptions
      }
    }
  }
`;

const fetchVariables = {};

export { fetchGQLEdit, fetchGQLNew, fetchVariables };