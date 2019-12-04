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
    
    let options;

    if(props.data.networkStatus === 7){
      options = props.data.supplies.nodes;
    }

    return {
      error: props.data.error,
      loading: props.data.loading,
      options: options ? options : [],
    }
  },
  skip: false,//props => !props.contractId,
  // name: ,
  // withRef: ,
  // alias: ,
};