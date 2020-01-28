import gql from 'graphql-tag';

const fetchAssetsString = gql`
query assetsQuery($category: AssetCategoryType!) {
  allAssets(condition: {category: $category}, orderBy: ASSET_SF_ASC) {
    edges {
      node {
        name
        model
        manufacturer
        assetSf
        category
        serialnum
        area
      }
    }
  }
}`;

export default fetchAssetsString;

