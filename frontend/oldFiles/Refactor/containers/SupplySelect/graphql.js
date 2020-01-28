import gql from 'graphql-tag';
import config from './config';

export const qQuery = gql`
  query ($contractId: Int) {
    supplies: allSuppliesLists(condition: {contractId: $contractId}) {
      nodes {
        supplyId
        supplySf
        name
        unit
        available
      }
    }
  }
`;

export const qConfig = {
  options: props => ({
    variables: {contractId: Number(props.queryCondition)},
    fetchPolicy: 'no-cache',
    errorPolicy: 'ignore',
    pollInterval: 0,
    notifyOnNetworkStatusChange: false,
  }),
  props: props => {

    if(props.data.networkStatus === 7){
      config.options = props.data.supplies.nodes.map(supply => {
        return {
          id: supply.supplyId,
          sf: supply.supplySf,
          name: supply.name,
          placeholder: supply.unit,
        }
      });
    }

    return {
      error: props.data.error,
      loading: props.data.loading,
      config: config,
    }
  },
  skip: false,//props => !props.contractId,
  // name: ,
  // withRef: ,
  // alias: ,
};