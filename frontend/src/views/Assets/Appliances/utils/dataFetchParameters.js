import gql from 'graphql-tag';

const fetchAppliancesGQL = gql`
  query MyQuery {
    queryResponse: allAppliances {
      nodes {
        assetId
        assetSf
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