import gql from 'graphql-tag';
import config from './config';

export const qQuery = gql`
  query MyQuery {
    orders: allOrders {
      nodes {
        orderId
        title
        category
        status
        createdAt
      }
    }
  }
`;

export const qConfig = {
  options: {
    variables: {},
    fetchPolicy: 'no-cache',
    errorPolicy: 'ignore',
    pollInterval: 0,
    notifyOnNetworkStatusChange: false,
  },
  props: props => {

    if(props.data.networkStatus === 7){
      config.list = props.data.orders.nodes.map(order => {
        order.createdAt = order.createdAt.split('T')[0];
        return order;
      });
    }

    return {
      error: props.data.error,
      loading: props.data.loading,
      columns: config.columns,
      list: config.list,
      title: config.title,
    }
  },
  skip: false,
  // name: ,
  // withRef: ,
  // alias: ,
};
