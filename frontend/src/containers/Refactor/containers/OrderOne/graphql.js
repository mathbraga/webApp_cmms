import gql from 'graphql-tag';
import getIdFromPath from '../../utils/getIdFromPath';
import config from './config';

const iFiles = config.tabs.findIndex(tab => tab.tabName === 'files');

export const qQuery = gql`
  query ($orderId: Int!) {
    one: allOrders(condition: {orderId: $orderId}) {
      nodes {
        orderId
        title
        description
        category
      }
    }
    files: allOrderFiles(condition: {orderId: $orderId}) {
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
  props: props => {

    if(props.data.networkStatus === 7){
      config.tabs[iFiles].list = props.data.files.nodes
      config.title = 'Ordem de Serviço #'+ props.data.one.nodes[0].orderId;
    }
    return {
      one: config,
      error: props.data.error,
      loading: props.data.loading,
    }
  },
  skip: false,
  // name: ,
  // withRef: ,
  // alias: ,
};