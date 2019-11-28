import gql from 'graphql-tag';
import paths from '../../../../paths';
import config from './config';

const iContract = config.inputs.findIndex(input => input.name === 'contractId');
const iAssets = config.inputs.findIndex(input => input.name === 'assets');
const iStatus = config.inputs.findIndex(input => input.name === 'status');
const iCategory = config.inputs.findIndex(input => input.name === 'category');
const iPriority = config.inputs.findIndex(input => input.name === 'priority');

export const qQuery = gql`
  query MyQuery {
    contracts: allContracts {
      nodes {
        contractId
        contractSf
        title
      }
    }
    assets: allAssets {
      nodes {
        assetId
        assetSf
        name
      }
    }
    statuses: __type (name: "OrderStatusType") {
      enumValues {
        name
      }
    }
    priorities: __type (name: "OrderPriorityType") {
      enumValues {
        name
      }
    }
    categories: __type (name: "OrderCategoryType"){
      enumValues {
        name
      }
    }
  }
`;

export const qConfig = {
  options: props => ({
    // variables: {},
    fetchPolicy: 'no-cache',
    errorPolicy: 'ignore',
    pollInterval: 0,
    notifyOnNetworkStatusChange: false,
  }),
  props: props => {

    if(props.data.networkStatus === 7){
      config.inputs[iContract].options = props.data.contracts.nodes.map(contract => ({
        value: contract.contractId,
        text: contract.contractSf + ' - ' + contract.title,
      }));
      config.inputs[iAssets].options = props.data.assets.nodes.map(asset => ({
        value: asset.assetId,
        text: asset.assetSf + ' - ' + asset.name,
      }));
      config.inputs[iCategory].options = props.data.categories.enumValues.map(category => ({
        value: category.name,
        text: category.name,
      }));
      config.inputs[iStatus].options = props.data.statuses.enumValues.map(status => ({
        value: status.name,
        text: status.name,
      }));
      config.inputs[iPriority].options = props.data.priorities.enumValues.map(priority => ({
        value: priority.name,
        text: priority.name,
      }));
    }


    return {
      error: props.data.error,
      loading: props.data.loading,
      data: props.data,
      form: config,
    }
  },
  skip: false,
  // name: ,
  // withRef: ,
  // alias: ,
};

export const mQuery = gql`
mutation MutationWithUpload (
  $attributes: OrderInput!,
  $assets: [Int!]!,
  $filesMetadata: [FileMetadatumInput]
) {
  insertOrder(
    input: {
      attributes: $attributes
      assets: $assets
      filesMetadata: $filesMetadata
    }
  ) {
    result
  }
}
`;

export const mConfig = {
  props: props => ({
    mutate: props.mutate,
  }),
  // name: ,
  // withRef: ,
  // alias: ,
  skip: false,
  options: props => ({
    // variables: {},
    // errorPolicy: ,
    // optimisticResponse: ,
    // refetchQueries: ,
    // update: ,
    // awaitRefetchQueries: ,
    // updateQueries: , // DEPRECATED
    // context: ,
    // client: ,
    // partialRefetch: ,
    fetchPolicy: 'no-cache',
    errorPolicy: 'ignore',
    pollInterval: 0,
    ignoreResults: false,
    notifyOnNetworkStatusChange: false,
    onCompleted: mData => {props.history.push(paths.ORDER + '/' + mData.insertOrder.result)},
    onError: error => {alert(error)},
  }),
};

export function getVariables(state){
  return {
    attributes: {
      title: state.title ? state.title : 'title',
      description: state.description ? state.description : 'description',
      status: state.status ? state.status : 'PEN',
      priority: state.priority ? state.priority : 'ALT',
      category: state.category ? state.category : 'ELE',
      parent: state.parent ? Number(state.parent) : null,
      contractId: state.contractId ? Number(state.contractId) : 1,
      departmentId: state.departmentId ? state.departmentId : 'departmentId',
      createdBy: state.createdBy ? state.createdBy : 'createdBy',
      contactName: state.contactName ? state.contactName : 'contactName',
      contactPhone: state.contactPhone ? state.contactPhone : 'phone',
      contactEmail: state.contactEmail ? state.contactEmail : 'email',
      place: state.place ? state.place : 'qualquer lugar',
      progress: state.progress ? Number(state.progress) : 99,
      dateLimit: state.dateLimit ? state.dateLimit : null,
      dateStart: state.dateStart ? state.dateStart : null,
      dateEnd: state.dateEnd ? state.dateEnd : null,
    },
    assets: state.assets ? state.assets : [1],
  }
};