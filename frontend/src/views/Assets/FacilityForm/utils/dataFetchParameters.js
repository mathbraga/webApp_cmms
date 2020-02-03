import gql from 'graphql-tag';

const fetchGQLEdit = gql`
  query MyQuery($assetId: Int!) {
    allAssetFormData {
      nodes {
        topOptions
        parentOptions
      }
    }
    allFacilityData(condition: {assetId: $assetId}) {
      nodes {
        assetId
        assetSf
        area
        categoryName
        description
        latitude
        longitude
        name
        tasks
      }
    }
  }
`;

const fetchGQLNew = gql`
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

export { fetchGQLEdit, fetchGQLNew, fetchVariables };