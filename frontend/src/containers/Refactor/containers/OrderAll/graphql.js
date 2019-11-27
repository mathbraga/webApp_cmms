import gql from 'graphql-tag';

export const qQuery = gql`
  query MyQuery {
    allOrders {
      nodes {
        orderId
        title
      }
    }
  }
`;

export const qConfig = {
  options: {
    variables: {},
    // fetchPolicy: 'no-cache',
    errorPolicy: 'ignore',
    pollInterval: 0,
    notifyOnNetworkStatusChange: false,
  },
  props: props => ({
    error: props.data.error,
    loading: props.data.loading,
    list: props.data.allOrders ? props.data.allOrders.nodes : null,
  }),
  skip: false,
  // name: ,
  // withRef: ,
  // alias: ,
};
