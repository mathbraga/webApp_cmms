import gql from 'graphql-tag';

const fetchGQLEdit = gql`
  query MyQuery($assetId: Int!) {
    allAssetFormData {
      nodes {
        topOptions
        parentOptions
      }
    }
    allApplianceData(condition: {assetId: $assetId}) {
      nodes {
        assetId
        assetSf
        contexts
        description
        manufacturer
        model
        name
        parents
        price
        serialnum
        tasks
      }
    }
  }
`;

const fetchGQLNew = gql`
  query MyQuery($assetId: Int!) {
    allAssetFormData {
      nodes {
        topOptions
        parentOptions
      }
    }
  }
`;

const fetchVariables = {};

export { fetchGQLEdit, fetchGQLNew, fetchVariables };