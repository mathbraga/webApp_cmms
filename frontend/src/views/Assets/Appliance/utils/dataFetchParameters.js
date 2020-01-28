import gql from 'graphql-tag';

const fetchGQL = gql`
  query ($assetId: Int!) {
    queryResponse: allApplianceData(condition: {assetId: $assetId}) {
      nodes {
        assetId
        assetSf
        categoryName
        description
        manufacturer
        model
        name
        price
        serialnum
        tasks
      }
    }
  }
`;

const fetchVariables = {};

export { fetchGQL, fetchVariables };