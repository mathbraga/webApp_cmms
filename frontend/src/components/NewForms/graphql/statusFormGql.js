import gql from 'graphql-tag';

export const MOVE_OPTIONS_QUERY = gql`
  query MoveOptionsQuery {
    allTaskData {
      nodes {
        moveOptions
      }
    }
  }
`;