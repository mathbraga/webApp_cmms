import gql from 'graphql-tag';

const mutationGQLEdit = gql`
  mutation (
    $attributes: AssetInput!,
    $tops: [Int!]!,
    $parents: [Int!]!
  ) {
  mutationResponse:  modifyAsset (
      input: {
        attributes: $attributes
        tops: $tops
        parents: $parents
      }
    ) {
      result
    }
  }
`;

const mutationGQLNew = gql`
  mutation (
    $attributes: AssetInput!,
    $tops: [Int!]!,
    $parents: [Int!]!
  ) {
  mutationResponse:  insertAsset (
      input: {
        attributes: $attributes
        tops: $tops
        parents: $parents
      }
    ) {
      result
    }
  }
`;

const mutationVariables = {};

export { mutationGQLEdit, mutationGQLNew, mutationVariables };