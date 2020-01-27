import gql from 'graphql-tag';

const fetchGQL = gql`
  query ($assetId: Int!) {
    queryResponse: allFacilityData(condition: {assetId: $assetId}) {
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

const fetchVariables = {};

export { fetchGQL, fetchVariables };