import gql from 'graphql-tag';

const fetchAppliancesGQL = gql`
query assetsQuery($category: AssetCategoryType!) {
  allAssets(condition: {category: $category}, orderBy: ASSET_SF_ASC) {
    nodes {
      name
      model
      manufacturer
      assetSf
      category
      serialnum
      area
    }
  }
}`;

const fetchAppliancesVariables = {
  category: "A"
};

export { fetchAppliancesGQL, fetchAppliancesVariables };