import gql from 'graphql-tag';
import config from './config';
import paths from '../../../../paths';
import getLocaleDate from '../../utils/getLocaleDate';
import getHrefPath from '../../utils/getHrefPath';

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
        order.createdAt = getLocaleDate(order.createdAt);
        order.href = getHrefPath(paths.ORDER, order.orderId);
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
