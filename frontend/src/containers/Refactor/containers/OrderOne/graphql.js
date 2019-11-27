import gql from 'graphql-tag';
import getIdFromPath from '../../utils/getIdFromPath';

export const qQuery = gql`
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

export const qConfig = {
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
    one: props.data.loading ? null : props.data.allTests.nodes[0],
    files: props.data.loading ? null : props.data.allTestFiles.nodes,
    error: props.data.error,
    loading: props.data.loading,
  }),
  skip: false,
  // name: ,
  // withRef: ,
  // alias: ,
};