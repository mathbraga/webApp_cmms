import gql from 'graphql-tag';
import paths from '../../../../paths';
import config from './config';

export const qQuery = gql`
  query MyQuery {
    allContracts {
      nodes {
        contractId
        contractSf
      }
    }
    allTests (orderBy: TEST_ID_ASC){
      nodes {
        testId
        testText
        contractId
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
  props: props => ({
    contracts: props.data.allContracts ? props.data.allContracts.nodes : [],
    error: props.data.error,
    loading: props.data.loading,
    data: props.data,
    form: props.data.allContracts ? config : config,
  }),
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
    onCompleted: mData => { console.log(mData); props.history.push(paths.ORDER + '/' + mData.insertOrder.result)},
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
      parent: state.parent ? state.parent : null,
      contractId: state.contractId ? state.contractId : 1,
      departmentId: state.departmentId ? state.departmentId : 'departmentId',
      createdBy: state.createdBy ? state.createdBy : 'createdBy',
      contactName: state.contactName ? state.contactName : 'contactName',
      contactPhone: state.contactPhone ? state.contactPhone : 'phone',
      contactEmail: state.contactEmail ? state.contactEmail : 'email',
      place: state.place ? state.place : 'qualquer lugar',
      progress: state.progress ? state.progress : 99,
      dateLimit: state.dateLimit ? state.dateLimit : null,
      dateStart: state.dateStart ? state.dateStart : null,
      dateEnd: state.dateEnd ? state.dateEnd : null,
    },
    assets: state.assets ? state.assets : [1],
  }
};