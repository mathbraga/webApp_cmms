import gql from 'graphql-tag';
import getIdFromPath from '../../utils/getIdFromPath';
import config from './config';

const iDetails = config.tabs.findIndex(tab => tab.tabName === 'details');
const iAssets = config.tabs.findIndex(tab => tab.tabName === 'assets');
const iSupplies = config.tabs.findIndex(tab => tab.tabName === 'supplies');
const iFiles = config.tabs.findIndex(tab => tab.tabName === 'files');

export const qQuery = gql`
  query ($orderId: Int!) {
    one: allVOrders(condition: {orderId: $orderId}) {
      nodes {
        orderId
        title
        description
        category
        assets
        supplies
        files
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
      const one = props.data.one.nodes[0];
      const { assets, supplies, files } = one;
      config.tabs[iDetails].table.rows.forEach(row => {
        row.value = one[row.field]
      });
      config.tabs[iAssets].table.rows = assets ? assets : [];
      config.tabs[iSupplies].table.rows = supplies ? supplies : [];
      config.tabs[iFiles].table.rows = files ? files : [];
      config.title = 'Ordem de Serviço #'+ one.orderId;
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