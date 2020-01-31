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
    assetChildren: getAssetTree(inputAssetId: $assetId){
      nodes{
        assets
        parentId
        topAsset
      }
    }
  }
`;

const fetchVariables = {};

export { fetchGQL, fetchVariables };