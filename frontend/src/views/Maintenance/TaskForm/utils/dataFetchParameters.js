import gql from 'graphql-tag';

const fetchGQL = gql`
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

export { fetchGQL, fetchVariables };