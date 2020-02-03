import gql from 'graphql-tag';

const fetchGQL = gql`
  query MyQuery {
    allTaskFormData {
      nodes {
        categoryOptions
        contractOptions
        priorityOptions
        statusOptions
        projectOptions
        teamOptions
      }
    }
  }
`;

const fetchVariables = {};

export { fetchGQL, fetchVariables };