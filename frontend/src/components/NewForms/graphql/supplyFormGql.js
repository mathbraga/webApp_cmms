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

export const INSERT_SUPPLY = gql`
  mutation SupplyTaskMutation($taskId: Int!, $supplyId: Int!, $qty: BigFloat!) {
    insertTaskSupply(input: {
      taskId: $taskId,
      supplyId: $supplyId,
      qty: $qty
    }) {
      id
    }
  }
`;
