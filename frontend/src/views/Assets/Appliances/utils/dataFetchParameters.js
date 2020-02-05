import gql from 'graphql-tag';

const fetchAppliancesGQL = gql`
  query MyQuery {
    queryResponse: allApplianceData {
      nodes {
        assetId
        assetSf
        categoryId
        description
        name
        manufacturer
        model
        price
        serialnum
      }
    }
  }
`;

const fetchAppliancesVariables = {};

export { fetchAppliancesGQL, fetchAppliancesVariables };