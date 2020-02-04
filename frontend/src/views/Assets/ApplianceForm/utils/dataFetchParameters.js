import gql from 'graphql-tag';

const fetchGQL = gql`
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

const fetchVariables = {};

export { fetchGQL, fetchVariables };