import gql from 'graphql-tag';
import getIdFromPath from '../../utils/getIdFromPath';

export const qQuery = gql`
  query ($orderId: Int!) {
    allOrders(condition: {orderId: $orderId}) {
      nodes {
        orderId
        title
        description
      }
    }
    allOrderFiles(condition: {orderId: $orderId}) {
      nodes {
        orderId
        filename
        uuid
        size
        personId
        createdAt
      }
    }
  }
`;

export const qConfig = {
  options: props => ({
    variables: {
      orderId: getIdFromPath(props.location.pathname)
    },
    fetchPolicy: 'no-cache',
    errorPolicy: 'ignore',
    pollInterval: 0,
    notifyOnNetworkStatusChange: false,
  }),
  props: props => ({
    one: props.data.loading ? null : props.data.allOrders.nodes[0],
    files: props.data.loading ? null : props.data.allOrderFiles.nodes,
    error: props.data.error,
    loading: props.data.loading,
  }),
  skip: false,
  // name: ,
  // withRef: ,
  // alias: ,
};