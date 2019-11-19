import gql from 'graphql-tag';

export const gqlQuery = gql`
  query MyQuery {
    allOrders {
      nodes {
        orderId
        title
      }
    }
  }
`;