import gql from 'graphql-tag';

const fetchGQL = gql`
  query MyQuery {
    allTaskFormData {
      nodes {
        categoryOptions
      }
    }
  }
`;

const fetchVariables = {};

export { fetchGQL, fetchVariables };