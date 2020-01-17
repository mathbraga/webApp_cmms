import gql from 'graphql-tag';

const fetchAppliancesGQL = gql`
  query ContractsQuery {
    allContracts(orderBy: CONTRACT_SF_ASC) {
      nodes {
        company
        contractSf
        dateStart
        dateEnd
        status
        title
        url
      }
    }
  }
`;

const fetchAppliancesVariables = {
};

export { fetchAppliancesGQL, fetchAppliancesVariables };