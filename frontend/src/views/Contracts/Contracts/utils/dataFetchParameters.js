import gql from 'graphql-tag';

const fetchAppliancesGQL = gql`
  query MyQuery {
    queryResponse: allContractData {
      nodes {
        contractSf
        contractId
        company
        contractStatusId
        contractStatusText
        dateEnd
        datePub
        dateSign
        dateStart
        description
        parent
        title
        url
      }
    }
  }
`;

const fetchAppliancesVariables = {
};

export { fetchAppliancesGQL, fetchAppliancesVariables };