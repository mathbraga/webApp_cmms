import gql from 'graphql-tag';
import paths from '../../../paths';

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
    fetchPolicy: 'cache-first',
    errorPolicy: 'ignore',
    pollInterval: 0,
    notifyOnNetworkStatusChange: false,
  }),
  // props: ,
  skip: false,
  // name: ,
  // withRef: ,
  // alias: ,
};

export const formConfig = {
  cardTitle: 'Título do formulário',
  inputs: [
    {
      id: 'text',
      label: 'text',
      name: 'text',
      type: 'text',
      value: 'hehhe',
      placeholder: 'text',
      required: false,
      selectDefault: null,
      selectOptions: [],
    },
    {
      id: 'contract',
      label: 'contract',
      name: 'contract',
      type: 'select',
      placeholder: 'contract',
      required: true,
      selectDefault: null,
      selectOptions: [
        {
          id: '1',
          name: '1',
          value: 1,
          label: '1'
        },
        {
          id: '2',
          name: '2',
          value: 2,
          label: '2'
        },
      ],
    }
  ]
};


export const mquery = gql`
mutation ($contractId: Int!, $testText: String!) {
  insertTest(input: {testAttributes: {contractId: $contractId, testText: $testText}}) {
    integer
  }
}
`;

export const mconfig = {
  // props: props => {},
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
    onCompleted: data => {props.history.push(paths.ORDER + '/' + data.insertTest.integer)},
    onError: error => {alert(error)},
  }),
};