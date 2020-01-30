import gql from 'graphql-tag';

const fetchGQL = gql`
  query ($assetId: Int!) {
    queryResponse: allFacilityData(condition: {assetId: $assetId}) {
      nodes {
        assetId
        assetSf
        area
        categoryName
        description
        latitude
        longitude
        name
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