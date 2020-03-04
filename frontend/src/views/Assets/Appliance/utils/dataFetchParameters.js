import gql from 'graphql-tag';

const fetchGQL = gql`
  query ($assetId: Int!) {
    queryResponse: allApplianceData(condition: {assetId: $assetId}) {
      nodes {
        assetId
        assetSf
        categoryId
        categoryName
        description
        manufacturer
        model
        name
        price
        serialnum
        tasks
        relations
      }
    }
  }
`;

const fetchVariables = {};

export { fetchGQL, fetchVariables };