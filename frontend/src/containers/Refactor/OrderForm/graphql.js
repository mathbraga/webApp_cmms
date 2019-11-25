import gql from 'graphql-tag';
import paths from '../../../paths';
import schema from '../../../schema.json';
import _ from 'lodash';

console.clear();
const types = schema.data.__schema.types
const i = _.findIndex(types, obj => obj.name === 'Person');
const fields = types[i].fields;
console.log(fields);
const formFields = [];
fields.forEach(field => {
  if(field.name !== 'nodeId' || field.type.kind === 'SCALAR'){
    formFields.push(field);
  }
});
console.log(formFields);

export const query = gql`
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

export const config = {
  options: props => ({
    // variables: {},
    fetchPolicy: 'no-cache',
    errorPolicy: 'ignore',
    pollInterval: 0,
    notifyOnNetworkStatusChange: false,
  }),
  props: props => ({
    contracts: props.data.allContracts ? props.data.allContracts.nodes : ['', ''],
    error: props.data.error,
    loading: props.data.loading,
    data: props.data,
  }),
  skip: false,
  // name: ,
  // withRef: ,
  // alias: ,
};

export const mquery = gql`
mutation MutationWithUpload (
  $contractId: Int!,
  $testText: String!,
  $filesMetadata: [TestFileInput]
) {
  insertTestAndUpload(
    input: {
      testAttributes: {
        contractId: $contractId,
        testText: $testText
      }
      filesMetadata: $filesMetadata
    }
  ) {
    integer
  }
}
`;

export const mconfig = {
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