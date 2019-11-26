import gql from 'graphql-tag';
import paths from '../../../../paths';

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
  }),
  skip: false,
  // name: ,
  // withRef: ,
  // alias: ,
};

export const mQuery = gql`
mutation MutationWithUpload (
  $contractId: Int!,
  $filesMetadata: [TestFileInput]
) {
  insertTestAndUpload(
    input: {
      testAttributes: {
        contractId: $contractId
      }
      filesMetadata: $filesMetadata
    }
  ) {
    integer
  }
}
`;

export const mConfig = {
  // props: props => ({
  //   mutationData: props.data,
  //   mutatie: props.mutate
  // }),
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
    onCompleted: data => {props.history.push(paths.ORDER + '/' + data.insertTestAndUpload.integer)},
    onError: error => {alert(error)},
  }),
};