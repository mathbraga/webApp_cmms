import gql from 'graphql-tag';

export const query = gql`
  query {
    allOrders {
      nodes {
        orderId
        title
        priority
      }
    }
  }
`;

export const config = {
  options: props => ({
    // variables: {},
    fetchPolicy: 'no-cache',
    errorPolicy: 'ignore',
    pollInterval: 0,
    notifyOnNetworkStatusChange: false,
  }),
  // props: ,
  skip: false,
  // name: ,
  // withRef: ,
  // alias: ,
};