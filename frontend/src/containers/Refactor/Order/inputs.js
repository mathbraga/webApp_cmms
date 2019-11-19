import gql from 'graphql-tag';

export const query = gql`
  query ($orderId: Int!) {
    allOrders(condition: {orderId: $orderId}) {
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
    variables: {orderId: Number(props.location.pathname.split('/')[2])},
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