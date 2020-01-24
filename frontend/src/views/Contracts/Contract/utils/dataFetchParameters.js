import gql from 'graphql-tag';

const fetchGQL = gql`
  query contract ($contractSf: String!){
    contractByContractSf(contractSf: $contractSf) {
      company
      contractSf
      dateEnd
      datePub
      dateSign
      dateStart
      description
      title
      url
    }
    allBalances(condition: {contractSf: $contractSf}) {
      nodes {
        available
        supplyId
        supplySf
        specId
        qty
        consumed
        title
        bidPrice
        blocked
        company
        contractId
        contractSf
        fullPrice
        name
        unit
      }
    }
  }
`;

const fetchVariables = {};

export { fetchGQL, fetchVariables };