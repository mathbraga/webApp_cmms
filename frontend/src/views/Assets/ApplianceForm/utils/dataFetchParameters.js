import gql from 'graphql-tag';

const fetchGQL = gql`
  query MyQuery {
    allAssetFormData {
      nodes {
        topOptions
        parentOptions
      }
    }
  }
`;

const fetchVariables = {};

export { fetchGQL, fetchVariables };