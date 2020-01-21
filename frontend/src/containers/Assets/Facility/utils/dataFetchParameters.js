import gql from 'graphql-tag';

const fetchGQL = gql`
  query ($assetSf: String!) {
    assetByAssetSf(assetSf: $assetSf) {
      area
      assetSf
      category
      description
      latitude
      longitude
      manufacturer
      model
      name
      nodeId
      orderAssetsByAssetId {
        nodes {
          orderByOrderId {
            category
            description
            dateLimit
            createdBy
            createdAt
            priority
            orderId
            status
            title
          }
        }
      }
    }
  }
`;

const fetchVariables = {};

export { fetchGQL, fetchVariables };