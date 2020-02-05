import gql from 'graphql-tag';

const fetchAppliancesGQL = gql`
  query MyQuery {
    queryResponse: allFacilityData {
      nodes {
        assetId
        assetSf
        categoryId
        area
        description
        latitude
        longitude
        name
      }
    }
  }
`;

const fetchAppliancesVariables = {};

export { fetchAppliancesGQL, fetchAppliancesVariables };