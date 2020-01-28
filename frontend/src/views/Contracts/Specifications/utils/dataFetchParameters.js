import gql from 'graphql-tag';

const fetchAppliancesGQL = gql`
  query MyQuery {
    queryResponse: allSpecData {
      nodes {
        specId
        specSf
        name
        specCategoryText
        specSubcategoryText
        totalAvailable
      }
    }
  }
`;

const fetchAppliancesVariables = {
};

export { fetchAppliancesGQL, fetchAppliancesVariables };