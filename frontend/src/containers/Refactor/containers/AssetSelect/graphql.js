import gql from 'graphql-tag';
import config from './config';

export const qQuery = gql`
  query {
    assets: allAssets {
      nodes {
        assetId
        assetSf
        name
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
      config.options = props.data.assets.nodes.map(asset => {
        return {
          id: asset.assetId,
          sf: asset.assetSf,
          name: asset.name,
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