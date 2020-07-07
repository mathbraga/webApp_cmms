import gql from 'graphql-tag';

export const ALL_ASSETS_QUERY = gql`
  query AssetsQuery {
    allTaskData {
      nodes {
        assetOptions
      }
    }
  }
`;