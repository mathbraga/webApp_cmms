import gql from 'graphql-tag';

const fetchAppliancesGQL = gql`
  query SpecsQuery {
    allSpecs(orderBy: SPEC_SF_ASC) {
      nodes {
        specSf
        specId
        version
        name
        category
        subcategory
      }
    }
  }
`;

const fetchAppliancesVariables = {
};

export { fetchAppliancesGQL, fetchAppliancesVariables };