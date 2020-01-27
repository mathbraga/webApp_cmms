import gql from 'graphql-tag';

const fetchGQL = gql`
  query MyQuery($contractId: Int!) {
    queryResponse: allContractData(condition: {contractId: $contractId}) {
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
        supplies
        title
        url
      }
    }
  }
`;

const fetchVariables = {};

export { fetchGQL, fetchVariables };