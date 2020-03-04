import gql from 'graphql-tag';

const fetchGQL = gql`
  query ($assetId: Int!) {
    queryResponse: allFacilityData(condition: {assetId: $assetId}) {
      nodes {
        assetId
        assetSf
        area
        categoryId
        categoryName
        description
        latitude
        longitude
        name
        tasks
        relations
      }
    }
  }
`;

const fetchVariables = {};

export { fetchGQL, fetchVariables };