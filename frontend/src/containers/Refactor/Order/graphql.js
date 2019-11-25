import gql from 'graphql-tag';
import getIdFromPath from '../getIdFromPath';

export const query = gql`
  query ($testId: Int!) {
    allTests(condition: {testId: $testId}) {
      nodes {
        testId
        contractId
        testText
      }
    }
    allTestFiles (condition: {testId: $testId}) {
      nodes {
        testId
        filename
        size
        uuid
        personId
        createdAt
      }
    }
  }
`;

export const config = {
  options: props => ({
    variables: {
      testId: getIdFromPath(props.location.pathname)
    },
    fetchPolicy: 'no-cache',
    errorPolicy: 'ignore',
    pollInterval: 0,
    notifyOnNetworkStatusChange: false,
  }),
  props: props => ({
    test: props.data.loading ? null : props.data.allTests.nodes[0],
    fileList: props.data.loading ? null : props.data.allTestFiles.nodes,
    error: props.data.error,
    loading: props.data.loading,
  }),
  skip: false,
  // name: ,
  // withRef: ,
  // alias: ,
};