import gql from 'graphql-tag';

export const SUPPLIES_QUERY = gql`
  query SuppliesQuery {
    allContractData {
      nodes {
        contractId
        contractSf
        company
        supplies
      }
    }
  }
`;