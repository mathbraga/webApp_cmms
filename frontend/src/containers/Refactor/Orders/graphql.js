import gql from 'graphql-tag';

export const query = gql`
  query MyQuery {
    allOrders {
      nodes {
        orderId
        title
      }
    }
  }
`;

export const config = {
  options: {
    variables: {},
    // fetchPolicy: 'no-cache',
    errorPolicy: 'ignore',
    pollInterval: 0,
    notifyOnNetworkStatusChange: false,
  },
  // props: ,
  skip: false,
  // name: ,
  // withRef: ,
  // alias: ,
};
