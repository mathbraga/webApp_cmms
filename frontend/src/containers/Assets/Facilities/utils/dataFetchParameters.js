import gql from 'graphql-tag';

const fetchAppliancesGQL = gql`
query assetsQuery($category: AssetCategoryType!) {
  allAssets(condition: {category: $category}, orderBy: ASSET_SF_ASC) {
    nodes {
      name
      assetSf
      category
      area
    }
  }
}`;

const fetchAppliancesVariables = {
  category: "F"
};

export { fetchAppliancesGQL, fetchAppliancesVariables };